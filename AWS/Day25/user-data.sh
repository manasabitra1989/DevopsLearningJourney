#!/bin/bash
set -eux

if command -v dnf >/dev/null 2>&1; then
    dnf install -y nginx
else
    apt-get update -y
    apt-get install -y nginx
fi

systemctl enable --now nginx

cat > /usr/share/nginx/html/index.html <<'EOF'
<h1>Hello from AWS EC2</h1>
<p>Day 25 - DevOps Winter Arc</p>
EOF
