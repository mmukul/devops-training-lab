# NextGen DevSecOps AI — Cloud Lab Phase 1A.2

## Goal

One-student AWS pilot with:

- Amazon Linux 2023 Kernel 6.18 x86_64
- t3.micro (use only if your AWS account shows Free Tier eligibility)
- 20 GB encrypted gp3
- AWS Systems Manager Session Manager
- Student login API
- 2 / 4 / 6 hour lab durations
- Automatic EC2 STOP at expiry
- Manual STOP

## Cost controls

- One EC2 instance only
- No NAT Gateway
- No load balancer
- No RDS/EKS/ECS
- T3 CPU credits set to Standard
- Maximum session duration is 6 hours
- Stopped EC2 does not incur instance compute charges, but EBS storage continues to incur charges

## Prerequisites

1. AWS CLI configured locally.
2. Terraform >= 1.6.
3. AWS account Free Tier eligibility verified in the AWS Billing/Free Tier console.
4. IAM permissions sufficient to create the resources in the Terraform files.

Verify identity:

```bash
aws sts get-caller-identity
aws configure set region ap-south-1
```

## Student password setup

For the pilot, use the helper script to create `terraform.tfvars` and generate the SHA-256 password hash locally. The plaintext password is not written to the configuration file:

```bash
./scripts/setup-student.sh
```

The script also generates a random admin API key and sets `terraform.tfvars` permissions to `600`. Do not commit `terraform.tfvars` to Git.

## Deploy

```bash
cd terraform
cp terraform.tfvars.example terraform.tfvars
# edit terraform.tfvars
terraform init
terraform fmt -recursive
terraform validate
terraform plan
terraform apply
```

## Important Phase 1A.2 limitation

The API and lifecycle automation are included, but the custom embedded browser terminal is intentionally **not exposed yet**. First validate that EC2 start/stop and the SSM connection work correctly. The next step is the terminal gateway and secure HTTPS endpoint.

For the pilot, the browser shell can be tested through AWS Systems Manager Session Manager while the terminal gateway is being added.

## Destroy the pilot

When finished testing:

```bash
terraform destroy
```

This terminates the pilot EC2 and removes the lab infrastructure. This is separate from the normal 2/4/6-hour runtime behavior, which only stops the EC2.
