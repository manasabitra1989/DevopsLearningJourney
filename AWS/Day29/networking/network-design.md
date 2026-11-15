# Day 29 — AWS Multi-AZ Network Design

Region: ap-south-1
VPC: vpc-0db58479bcc738ebc
VPC CIDR: 172.31.0.0/16

## Existing public subnets

AZ ap-south-1a:
subnet-00698086d711aa54c

AZ ap-south-1b:
subnet-0411976d508d370d9

## Proposed private subnets (not deployed)

Private subnet A:
AZ: ap-south-1a
CIDR: 172.31.96.0/24

Private subnet B:
AZ: ap-south-1b
CIDR: 172.31.97.0/24

Note: Proposed CIDRs must be checked against
existing subnet CIDRs before actual deployment.

## Routing design

Public subnets:
0.0.0.0/0 -> Internet Gateway

Private subnets:
VPC local route only initially.

Outbound package installation requires a
separately planned NAT or alternative method.

## Security design

Internet -> ALB : TCP 80
ALB -> EC2 : TCP 80
EC2 -> RDS : TCP 5432

## Auto Scaling

Minimum instances: 2
Desired instances: 2
Maximum instances: 4

## Deployment status

DESIGN ONLY — No AWS resources created.
