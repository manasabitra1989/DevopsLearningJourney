# Day 25/90 – AWS EC2 Web Server, EBS, IAM & Session Manager

## Objective
Launch a real AWS EC2 instance, bootstrap Nginx automatically, expose a web page over HTTP, connect via SSH and Session Manager, inspect EBS storage, and safely clean up temporary AWS resources.

## Environment
- AWS Region: `ap-south-1` (Mumbai)
- OS: Amazon Linux 2023
- EC2 instance type: `t3.micro`
- Root EBS volume: 8 GiB, `gp3`, XFS filesystem
- Application: Nginx serving a simple HTML page
- Client: Debian Linux on WSL, AWS CLI (`devops-learner` profile)
- Security group: `day25-nginx-sg`
- SSH key pair: `day25-ec2-key`
- SSM IAM role: `Day25-EC2-SSM-Role` with `AmazonSSMManagedInstanceCore`

> **Security:** The public IP, instance IDs and other temporary identifiers are omitted from this README. Do not commit private SSH keys, AWS credentials or access tokens to GitHub.

## Architecture

```text
Laptop (Debian WSL / browser)
       |                  \
       | SSH (TCP 22)      \ HTTP (TCP 80)
       v                    v
  EC2 Security Group --> EC2 (Amazon Linux 2023)
                              |-- User Data --> Nginx --> HTML page
                              |-- 8 GiB gp3 EBS root volume (XFS)
                              |-- SSM Agent --> AWS Systems Manager
                              |                 ^
                              +-- IAM instance profile / role
```

## What I practiced

1. Configured AWS CLI authentication and selected the Mumbai Region.
2. Created an RSA SSH key pair and restricted its local permissions (`chmod 400`).
3. Created a security group: HTTP 80 from the internet and SSH 22 from my current public IP only; outbound traffic allowed.
4. Created `user-data.sh` to install and enable Nginx and publish a sample HTML page at instance boot.
5. Launched an Amazon Linux 2023 `t3.micro` instance with a public IPv4 address and an 8 GiB `gp3` root volume.
6. Verified the instance passed EC2 status checks and accessed the web page in a browser and with `curl`.
7. Connected through SSH as `ec2-user` and verified the operating system and Nginx service.
8. Inspected storage with `lsblk`, `df -h`, and `findmnt /`; observed an XFS root filesystem and confirmed **Delete on termination = Yes**.
9. Checked the preinstalled SSM Agent and investigated its initial credential errors.
10. Created an EC2-trusted IAM role with `AmazonSSMManagedInstanceCore` and attached its instance profile.
11. Restarted the SSM Agent to refresh credentials; successfully connected using AWS Systems Manager Session Manager.

## User Data script

File: `user-data.sh`

```bash
#!/bin/bash
set -eux

if command -v dnf >/dev/null 2>&1; then
    dnf install -y nginx
else
    apt-get update -y
    apt-get install -y nginx
fi

systemctl enable --now nginx

cat > /usr/share/nginx/html/index.html <<'HTML'
<h1>Hello from AWS EC2</h1>
<p>Day 25 - DevOps Winter Arc</p>
HTML
```

## Useful commands

Run AWS CLI commands from the Debian WSL terminal unless otherwise noted.

```bash
# Verify identity and region
aws sts get-caller-identity
aws configure get region

# List EC2 instances and public IPs
aws ec2 describe-instances \
  --query 'Reservations[].Instances[].[InstanceId,State.Name,PublicIpAddress]' \
  --output table

# Inspect the security group
aws ec2 describe-security-groups \
  --group-names day25-nginx-sg --output table

# Test the public web page (while EC2 is running)
curl http://<PUBLIC_IP>

# Connect via SSH (while EC2 is running)
ssh -i ~/.ssh/day25-ec2-key.pem ec2-user@<PUBLIC_IP>

# Commands to run inside the EC2 instance
whoami
hostname
cat /etc/os-release
sudo systemctl status nginx
lsblk
df -h
findmnt /
sudo systemctl status amazon-ssm-agent
sudo journalctl -u amazon-ssm-agent -n 30 --no-pager
sudo systemctl restart amazon-ssm-agent

# Verify attached IAM instance profile
aws ec2 describe-instances \
  --query 'Reservations[].Instances[].[InstanceId,IamInstanceProfile.Arn]' \
  --output table

# Verify SSM managed-node status
aws ssm describe-instance-information \
  --region ap-south-1 \
  --query 'InstanceInformationList[].[InstanceId,PingStatus,AgentVersion]' \
  --output table
```

## Troubleshooting notes

- **Initial key-pair creation denied:** IAM user lacked `ec2:CreateKeyPair` permissions; added the required authorization.
- **SSM Agent running but not connected:** The instance initially had no IAM instance profile; agent logs reported `no EC2 IMDS role found`.
- **Resolution:** Created an EC2 IAM role with `AmazonSSMManagedInstanceCore`, attached the role, and restarted the SSM Agent. Session Manager connectivity then succeeded.
- **Key distinction:** IAM permissions for the AWS CLI user are different from permissions granted to the EC2 instance through an IAM role.

## Cleanup – PENDING

**Status:** At the time of writing, the instance was still running; termination and cleanup have **not yet been confirmed**. Update this section only after completing the steps below.

1. Save any evidence you need, then terminate the lab instance:

   ```bash
   aws ec2 terminate-instances --instance-ids <INSTANCE_ID> --region ap-south-1
   aws ec2 wait instance-terminated --instance-ids <INSTANCE_ID> --region ap-south-1
   ```

2. Verify the lab root EBS volume has been deleted; check EC2 **Volumes** for any remaining lab volumes. Do not delete unrelated resources.
3. Delete the temporary security group once it is no longer attached to an instance:

   ```bash
   aws ec2 delete-security-group --group-name day25-nginx-sg --region ap-south-1
   ```

4. Delete the temporary EC2 key pair in AWS and the local private key **only if it is no longer needed**:

   ```bash
   aws ec2 delete-key-pair --key-name day25-ec2-key --region ap-south-1
   rm ~/.ssh/day25-ec2-key.pem
   ```

5. Detach/delete the temporary IAM role and its instance profile using IAM Console, after verifying no other resources use them. The AWS-managed policy itself should **not** be deleted.
6. Review Elastic IPs, snapshots, retained volumes and billing for any leftover lab charges.

## Key takeaways

- **EC2** supplies virtual compute; **EBS** provides block storage.
- **Security groups** control inbound and outbound network access.
- **User Data** automates initial server configuration.
- **SSH** authenticates using a key; **Session Manager** uses AWS IAM and an SSM Agent without requiring inbound SSH.
- **IAM roles** provide EC2 workloads temporary AWS credentials without hard-coding keys.
- **Cleanup** is part of safe, cost-aware cloud engineering.

## Repository layout

```text
AWS/
└── Day25/
    ├── README.md
    └── user-data.sh
```
