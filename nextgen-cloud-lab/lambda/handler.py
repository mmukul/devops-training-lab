import hashlib
import json
import os
from datetime import datetime, timezone, timedelta

import boto3

ec2 = boto3.client("ec2")

PROJECT = os.environ["PROJECT_NAME"]
INSTANCE_ID = os.environ["INSTANCE_ID"]
ADMIN_API_KEY = os.environ["ADMIN_API_KEY"]
STUDENT_USERNAME = os.environ["STUDENT_USERNAME"]
STUDENT_PASSWORD_HASH = os.environ["STUDENT_PASSWORD_HASH"]
DURATIONS = {2: 2, 4: 4, 6: 6}

# Pilot note: state is stored in EC2 tags so we avoid adding DynamoDB in Phase 1A.
def response(status, body):
    return {
        "statusCode": status,
        "headers": {"content-type": "application/json", "access-control-allow-origin": "*"},
        "body": json.dumps(body),
    }

def password_ok(password):
    return hashlib.sha256(password.encode()).hexdigest() == STUDENT_PASSWORD_HASH

def instance():
    r = ec2.describe_instances(InstanceIds=[INSTANCE_ID])
    return r["Reservations"][0]["Instances"][0]

def set_tags(tags):
    ec2.create_tags(Resources=[INSTANCE_ID], Tags=[{"Key": k, "Value": v} for k, v in tags.items()])

def api_key_ok(event):
    return event.get("headers", {}).get("x-api-key") == ADMIN_API_KEY

def lambda_handler(event, context):
    # EventBridge expiry invocation
    if event.get("action") == "expire":
        try:
            i = instance()
            tags = {t["Key"]: t["Value"] for t in i.get("Tags", [])}
            expiry = tags.get("LabExpiry")
            if expiry and i["State"]["Name"] == "running":
                if datetime.now(timezone.utc) >= datetime.fromisoformat(expiry):
                    ec2.stop_instances(InstanceIds=[INSTANCE_ID])
                    set_tags({"LabState": "STOPPED", "LabExpiry": ""})
            return response(200, {"ok": True})
        except Exception as exc:
            print(exc)
            return response(500, {"error": "expiry check failed"})

    if not api_key_ok(event):
        return response(401, {"error": "unauthorized"})

    try:
        body = json.loads(event.get("body") or "{}")
        action = body.get("action")

        if action == "login":
            if body.get("username") == STUDENT_USERNAME and password_ok(body.get("password", "")):
                return response(200, {"ok": True, "student": STUDENT_USERNAME})
            return response(401, {"error": "invalid credentials"})

        if action == "status":
            i = instance()
            tags = {t["Key"]: t["Value"] for t in i.get("Tags", [])}
            return response(200, {
                "state": i["State"]["Name"],
                "lab_expiry": tags.get("LabExpiry"),
                "public_ip": i.get("PublicIpAddress"),
            })

        if action == "launch":
            duration = int(body.get("duration", 0))
            if duration not in DURATIONS:
                return response(400, {"error": "duration must be 2, 4 or 6 hours"})
            i = instance()
            if i["State"]["Name"] == "running":
                return response(409, {"error": "lab is already running"})
            now = datetime.now(timezone.utc)
            expiry = now + timedelta(hours=duration)
            ec2.start_instances(InstanceIds=[INSTANCE_ID])
            set_tags({"LabState": "RUNNING", "LabStart": now.isoformat(), "LabExpiry": expiry.isoformat()})
            return response(202, {"state": "starting", "duration": duration, "lab_expiry": expiry.isoformat()})

        if action == "stop":
            ec2.stop_instances(InstanceIds=[INSTANCE_ID])
            set_tags({"LabState": "STOPPED", "LabExpiry": ""})
            return response(200, {"state": "stopping"})

        return response(400, {"error": "unknown action"})
    except Exception as exc:
        print(exc)
        return response(500, {"error": "internal error"})
