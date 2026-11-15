# Day 29 — Failure Recovery Test Plan

Status: DESIGN ONLY — NOT EXECUTED

## Prerequisites

- ALB deployed in two public subnets
- ASG deployed across two private subnets
- Desired capacity: 2
- Two healthy EC2 targets
- Nginx displaying EC2 instance IDs

## Test 1 — Verify Load Balancing

Command (only after deployment):

for i in 1 2 3 4 5 6; do
  curl -s http://<ALB_DNS_NAME>
  echo
done

Expected:
Responses should eventually show two different
EC2 instance IDs.

## Test 2 — Simulate Instance Failure

1. Identify an EC2 instance belonging to
   the Day 29 Auto Scaling Group.
2. Confirm it is not a shared instance.
3. Terminate that lab instance.
4. Monitor ALB target health.
5. Observe ASG replacement activity.

Expected:
- ALB stops routing to unhealthy targets.
- Healthy remaining instance serves requests.
- ASG launches a replacement instance.
- Replacement becomes healthy.

## Test 3 — Verify Recovery

Check target health:

aws elbv2 describe-target-health \
  --target-group-arn <TARGET_GROUP_ARN>

Check ASG activity:

aws autoscaling describe-scaling-activities \
  --auto-scaling-group-name <ASG_NAME>

Expected:
Two healthy targets after recovery.

## Important Limitations

- No live failure test was performed.
- Zero downtime has not been demonstrated.
- No replacement instance was launched.
- Actual results must be recorded after deployment.
