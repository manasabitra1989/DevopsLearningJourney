#!/bin/bash
set -euo pipefail

TOKEN=$(curl -fsS -X PUT \
  -H "X-aws-ec2-metadata-token-ttl-seconds: 21600" \
  http://169.254.169.254/latest/api/token)

INSTANCE_ID=$(curl -fsS \
  -H "X-aws-ec2-metadata-token: ${TOKEN}" \
  http://169.254.169.254/latest/meta-data/instance-id)

cat > /usr/share/nginx/html/index.html <<HTML
<!DOCTYPE html>
<html>
<head>
  <title>DevOps Winter Arc - Day 29</title>
</head>
<body>
  <h1>High Availability Application</h1>
  <h2>DevOps Winter Arc - Day 29</h2>
  <p>Served by EC2 Instance: ${INSTANCE_ID}</p>
  <p>Running behind AWS Application Load Balancer</p>
</body>
</html>
HTML

systemctl enable --now nginx
