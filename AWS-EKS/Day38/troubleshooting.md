# Day 38 – Kubernetes Scheduling Troubleshooting

## Problem

The `capacity-test` Pod remained in `Pending` status and was not assigned to a Kubernetes node.

## Evidence

- Pod status: `Pending`
- PodScheduled condition: `False`
- Assigned node: `none`
- CPU request: `100m`
- Memory request: `3Gi`
- Node allocatable memory: approximately `2.02Gi`

Kubernetes event:

```text
Warning FailedScheduling
0/1 nodes are available: 1 Insufficient memory.
```

## Root Cause

The Pod requested `3Gi` of memory, exceeding the memory allocatable on the only Kubernetes node.

The scheduler could not place the Pod.

## Fix / Recommendation

For a real application, choose one of the following based on actual workload needs:

- Reduce the memory request to a realistic value supported by application testing.
- Add worker-node capacity.
- Use a larger worker node.
- Configure an appropriate node autoscaling solution when applicable.

## Verification

The `kubectl describe pod capacity-test` output confirmed the `Insufficient memory` scheduling failure.

After applying an appropriate capacity or request change, verify that the Pod becomes scheduled and reaches `Running` and `Ready`.

## Environment

- Floci local AWS emulator
- Local K3s Kubernetes runtime
- No real AWS EC2 worker nodes created
