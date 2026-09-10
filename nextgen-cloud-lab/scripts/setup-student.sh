#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "$0")/.." && pwd)"
TF_DIR="$ROOT_DIR/terraform"
VARS_FILE="$TF_DIR/terraform.tfvars"
EXAMPLE="$TF_DIR/terraform.tfvars.example"

command -v sha256sum >/dev/null 2>&1 || { echo "sha256sum is required."; exit 1; }

if [[ -f "$VARS_FILE" ]]; then
  echo "terraform.tfvars already exists: $VARS_FILE"
  echo "Edit it directly, or remove it and rerun this script."
  exit 1
fi

cp "$EXAMPLE" "$VARS_FILE"
read -r -p "Student username [student01]: " USERNAME
USERNAME="${USERNAME:-student01}"
read -r -s -p "Student password: " PASSWORD
printf '\n'
read -r -s -p "Confirm password: " PASSWORD2
printf '\n'
[[ "$PASSWORD" == "$PASSWORD2" ]] || { echo "Passwords do not match."; rm -f "$VARS_FILE"; exit 1; }
[[ -n "$PASSWORD" ]] || { echo "Password cannot be empty."; rm -f "$VARS_FILE"; exit 1; }

HASH="$(printf '%s' "$PASSWORD" | sha256sum | awk '{print $1}')"
ADMIN_KEY="$(python3 - <<'PY'
import secrets
print(secrets.token_urlsafe(32))
PY
)"

python3 - "$VARS_FILE" "$USERNAME" "$HASH" "$ADMIN_KEY" <<'PY'
from pathlib import Path
import sys
p = Path(sys.argv[1])
s = p.read_text()
s = s.replace('student_id           = "student01"', f'student_id           = "{sys.argv[2]}"')
s = s.replace('student_username     = "student01"', f'student_username     = "{sys.argv[2]}"')
s = s.replace('student_password_hash = "SHA256_HEX_HASH_OF_PASSWORD"', f'student_password_hash = "{sys.argv[3]}"')
s = s.replace('admin_api_key        = "CHANGE_ME"', f'admin_api_key        = "{sys.argv[4]}"')
p.write_text(s)
PY
chmod 600 "$VARS_FILE"
echo "Created $VARS_FILE with a SHA-256 password hash."
echo "Next: cd terraform && terraform init && terraform validate && terraform plan"
