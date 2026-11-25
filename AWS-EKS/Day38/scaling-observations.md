# Day 38 – Deployment Scaling vs Node Group Scaling

## Objective

Understand the difference between scaling Kubernetes application Pods and scaling AWS EKS EC2 worker nodes.

## Environment

- AWS API simulation: Floci
- Kubernetes runtime: Local K3s
- Deployment: `node-capacity-demo`
- Kubernetes nodes: 1

## Experiment

Initially, the Deployment contained two Ready Nginx replicas.

I executed:

```bash
docker exec floci-aws-eks-winter-arc-eks \
  kubectl scale deployment node-capacity-demo --replicas=3
```

## Observations

| Resource | Before | After |
|---|---|---|
| Nginx replicas | 2 | 3 |
| Ready Nginx Pods | 2 | 3 |
| Kubernetes nodes | 1 | 1 |
| Nginx CPU requests | 200m | 300m |
| Nginx memory requests | 256Mi | 384Mi |

The additional Pod was successfully scheduled on the existing Kubernetes node.

## Key Learning

Deployment scaling changes the desired number of application Pods.

Managed node group scaling changes the number of EC2 worker nodes available to run Pods in a real EKS environment.

Increasing replicas does not by itself create additional EC2 worker nodes.

## Conclusion

The experiment confirmed that the Kubernetes Deployment scaled from two to three Ready Pods while the local Kubernetes node count remained unchanged.

This was a local Kubernetes scheduling experiment, not real AWS EC2 node group scaling.
