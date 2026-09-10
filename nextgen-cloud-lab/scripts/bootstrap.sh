#!/bin/bash
set -euxo pipefail

# Phase 1A.2 bootstrap for Amazon Linux 2023 Kernel 6.18.
# SSM Agent is preinstalled on AL2023; keep the instance minimal for cost.
dnf update -y

dnf install -y git curl jq unzip

# Keep SSH disabled at the network layer. Session Manager is used for administration.
# Browser terminal application will be added after the infrastructure test passes.

echo "NextGen DevSecOps AI Cloud Lab ready" > /etc/nextgen-lab-ready
