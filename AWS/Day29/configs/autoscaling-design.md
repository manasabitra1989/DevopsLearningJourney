# Day 29 — ALB and Auto Scaling Design

## Application Load Balancer

Name: day29-alb
Scheme: internet-facing
Type: application
Listener: HTTP 80
Security Group: alb-sg

Public subnets:
- ap-south-1a
- ap-south-1b

## Target Group

Name: day29-target-group
Target Type: instance
Protocol: HTTP
Port: 80
Health Check Protocol: HTTP
Health Check Path: /
Success Code: 200

## Auto Scaling Group

Name: day29-asg
Launch Template: Day29 launch template

Private subnets:
- ap-south-1a
- ap-south-1b

Minimum Capacity: 2
Desired Capacity: 2
Maximum Capacity: 4

Health Check Type: ELB
Health Check Grace Period: 300 seconds

## Scaling Policy

Type: Target Tracking
Metric: ASGAverageCPUUtilization
Target Value: 50%

## Expected Failure Recovery

1. Two EC2 instances become healthy.
2. ALB distributes requests between them.
3. One instance becomes unhealthy.
4. ALB stops routing to that instance.
5. ASG launches a replacement instance.
6. Bootstrap installs and starts Nginx.
7. Replacement passes health checks.
8. ALB resumes routing across healthy targets.

## Important

This is a design-only configuration.

No ALB, Target Group, EC2 instance or
Auto Scaling Group has been created.

Actual failover and scaling remain untested.
