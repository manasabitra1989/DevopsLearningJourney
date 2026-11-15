# Day 29 — Security Group Design

Region: ap-south-1
VPC: vpc-0db58479bcc738ebc

## 1. alb-sg

Purpose: Protect the public Application Load Balancer.

Inbound:
- TCP 80 from 0.0.0.0/0

Outbound:
- TCP 80 to app-sg

## 2. app-sg

Purpose: Protect private EC2 application instances.

Inbound:
- TCP 80 from alb-sg

Outbound:
- TCP 5432 to db-sg
- TCP 443 to required AWS services, if needed
- Additional outbound access for bootstrap only
  when explicitly planned

## 3. db-sg

Purpose: Protect private RDS PostgreSQL.

Inbound:
- TCP 5432 from app-sg

Outbound:
- Review based on database requirements.

## Security principles

1. Never expose RDS directly to the internet.
2. Do not assign public IPs to private EC2 instances.
3. Use security group references instead of
   hardcoded application IP addresses.
4. Follow least-privilege access.
5. Use HTTPS with ACM in production.

## Deployment status

DESIGN ONLY.
No AWS security groups have been created.
