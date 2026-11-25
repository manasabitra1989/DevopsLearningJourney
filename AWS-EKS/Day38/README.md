# Day 38 – AWS EKS Managed Node Groups

## Overview

This assignment explores Amazon EKS managed node groups, EC2 worker-node capacity, Kubernetes scheduling, resource requests, scaling and troubleshooting.

The AWS EKS API operations were practised using the local Floci emulator. Kubernetes workload experiments were performed on Floci's local K3s runtime.

**No real AWS EKS cluster or EC2 managed node group was provisioned.**

## Objectives

- Understand EKS managed node groups.
- Design worker capacity across two private subnets.
- Understand minimum, desired and maximum node counts.
- Inspect Kubernetes node resources and conditions.
- Deploy an application with resource requests.
- Troubleshoot a Pod stuck in Pending.
- Compare Deployment scaling with node group scaling.

## Environment

| Component | Environment |
|---|---|
| Operating system | Debian 13 on WSL2 |
| AWS simulator | Floci |
| Floci CLI | 0.4.0 |
| Floci server | 2.5.0 |
| Kubernetes | Local K3s v1.29.14+k3s1 |
| AWS Region (simulated) | us-east-1 |
| Cluster | winter-arc-eks |

## Task A – Managed Node Group Design

Planned node group configuration:

| Configuration | Value |
|---|---|
| Node group | winter-arc-node-group |
| Instance type | t3.small (candidate) |
| Minimum nodes | 2 |
| Desired nodes | 2 |
| Maximum nodes | 3 |
| Disk size | 20 GiB |
| Network | Two private subnets |
| Availability Zones | Two |
| Node label | workload=web |

See [Node Group Design](node-group-design.md) and [Architecture](node-group-architecture.md).

## Task B – Floci EKS Inspection

The local simulated EKS cluster was successfully inspected.

```text
Cluster: winter-arc-eks
Status: ACTIVE
Version: 1.29
Managed node groups: []
```

The absence of managed node groups means that no node group was recorded in Floci.

The local Kubernetes runtime is not equivalent to real EC2 managed node groups.

See [Floci Inspection](floci-inspection.md).

## Task C – Kubernetes Node Inspection

The local Kubernetes environment contained one Ready K3s node.

Observed capacity:

| Resource | Value |
|---|---|
| CPU capacity | 4 cores |
| CPU allocatable | 1930m |
| Memory capacity | Approximately 3.72 GiB |
| Memory allocatable | Approximately 2.02 GiB |
| Node taints | None |
| Ready condition | True |

The node reported no memory, disk or PID pressure.

## Task D – Pod Scheduling

A Deployment named `node-capacity-demo` was created using two Nginx replicas.

Each replica requested:

```yaml
resources:
  requests:
    cpu: 100m
    memory: 128Mi
```

Both Pods were successfully scheduled and reached Running/Ready status on the same local Kubernetes node.

See [Deployment YAML](node-capacity-demo.yaml).

## Insufficient Capacity Experiment

A Pod named `capacity-test` was created requesting:

```yaml
resources:
  requests:
    cpu: 100m
    memory: 3Gi
```

The scheduler could not find a node with sufficient memory.

Observed event:

```text
Warning FailedScheduling
0/1 nodes are available: 1 Insufficient memory.
```

The Pod remained Pending without a node assignment.

See [Troubleshooting Report](troubleshooting.md).

## Deployment Scaling Experiment

The Nginx Deployment was scaled from two replicas to three and then restored to two.

| Measurement | Initial | Scaled up | Restored |
|---|---|---|---|
| Nginx Pods | 2 | 3 | 2 |
| Kubernetes nodes | 1 | 1 | 1 |

This demonstrated that scaling Deployment replicas does not automatically increase worker-node capacity.

See [Scaling Observations](scaling-observations.md).

## Deployment Scaling vs Node Group Scaling

**Deployment scaling** changes the desired number of application Pods.

**Managed node group scaling** changes the desired EC2 worker-node capacity in real Amazon EKS.

Node autoscaling requires appropriate configuration and cannot be assumed to occur whenever replicas increase.

## Troubleshooting Lessons

- Check `kubectl describe pod` when a Pod remains Pending.
- Check resource requests against node allocatable capacity.
- Check node conditions and taints.
- Inspect Kubernetes events for scheduling failures.
- Verify actual Pod placement using `kubectl get pods -o wide`.

## Cost and Safety

This assignment used Floci and a local Kubernetes runtime rather than provisioning real AWS worker nodes.

A real EKS deployment would require reviewing EKS cluster charges, EC2 instances, EBS storage, networking, NAT Gateways and related services.

Real AWS provisioning requires budget approval.

## Cleanup

The `capacity-test` Pod is no longer present.

The Nginx Deployment was restored to two replicas. It can be removed after capturing the required evidence using:

```bash
docker exec floci-aws-eks-winter-arc-eks \
  kubectl delete deployment node-capacity-demo
```

## Key Learnings

1. EKS managed node groups provide EC2 worker-node capacity.
2. Minimum, desired and maximum values define node group scaling boundaries.
3. Kubernetes schedules Pods using resource requests and other scheduling constraints.
4. A Pod can remain Pending because of insufficient resources.
5. Deployment scaling is different from worker-node scaling.
6. Floci can support AWS API learning, but a local simulation does not prove real AWS infrastructure exists.

## Conclusion

Day 38 demonstrated EKS node group planning, local EKS API inspection, Kubernetes node capacity analysis, Pod scheduling, insufficient memory troubleshooting, and Deployment replica scaling.
