#!/bin/bash
set -euo pipefail

# Install Nginx on Amazon Linux 2023
dnf install -y nginx curl

# Retrieve IMDSv2 session token
TOKEN=$(curl -fsS --retry 3 -X PUT \
  "http://169.254.169.254/latest/api/token" \
  -H "X-aws-ec2-metadata-token-ttl-seconds: 21600")

# Retrieve EC2 instance ID
INSTANCE_ID=$(curl -fsS --retry 3 \
  -H "X-aws-ec2-metadata-token: $TOKEN" \
  "http://169.254.169.254/latest/meta-data/instance-id")

# Create the Nginx application page
cat > /usr/share/nginx/html/index.html <<HTML
<!DOCTYPE html>
<html>
<head>
  <title>Day 29 - AWS HA App</title>
</head>
<body>
  <h1>DevOps Winter Arc - Day 29</h1>
  <h2>High Availability Application</h2>
  <p>Served by EC2: ${INSTANCE_ID}</p>
</body>
</html>
HTML

# Enable and start Nginx
systemctl enable --now nginx
