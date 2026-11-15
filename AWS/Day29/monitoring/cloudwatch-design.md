# Day 29 — CloudWatch Monitoring Design

Status: DESIGN ONLY — NOT DEPLOYED

## 1. Monitoring Goals

Monitor application availability, load,
server health and scaling activity.

## 2. Metrics

EC2:
- CPUUtilization

Auto Scaling:
- GroupDesiredCapacity
- GroupInServiceInstances

Application Load Balancer:
- RequestCount
- HTTPCode_ELB_5XX_Count
- HealthyHostCount
- UnHealthyHostCount

## 3. Auto Scaling Policy

Policy Type: Target Tracking
Metric: ASGAverageCPUUtilization
Target Value: 50%

Minimum Capacity: 2
Desired Capacity: 2
Maximum Capacity: 4

Note:
Target tracking aims to maintain average CPU
near 50%. Scaling is not instantaneous.

## 4. CloudWatch Alarm Design

Alarm Name: day29-unhealthy-hosts

Metric Namespace: AWS/ApplicationELB
Metric Name: UnHealthyHostCount
Statistic: Maximum
Period: 60 seconds
Threshold: >= 1
Evaluation Periods: 2

Dimensions required after deployment:
- LoadBalancer
- TargetGroup

Alarm Action:
Optional SNS email notification.

## 5. Dashboard Design

Dashboard Name: Day29-HA-Dashboard

Widgets:
1. ALB RequestCount
2. ALB HealthyHostCount
3. ALB UnHealthyHostCount
4. ALB HTTPCode_ELB_5XX_Count
5. EC2 CPUUtilization
6. ASG GroupInServiceInstances

## 6. Expected Failure Observations

1. An EC2 instance becomes unhealthy.
2. ALB stops normal routing to that target.
3. ASG detects unhealthy capacity.
4. ASG launches a replacement.
5. Replacement passes health checks.
6. Healthy target count returns to two.

## 7. Deployment Status

No CloudWatch alarms or dashboards created.
No SNS resources created.
No live metrics or alarms verified.
