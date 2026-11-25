
# AWS EKS Managed Node Group Architecture

This is a proposed architecture for Day 38.
No real AWS infrastructure has been provisioned.

```mermaid
flowchart TD
    A["Amazon EKS Control Plane"]
    B["Managed Node Group: winter-arc-node-group"]
    C["Private Subnet A - AZ 1"]
    D["Private Subnet B - AZ 2"]
    E["EC2 Worker Node 1"]
    F["EC2 Worker Node 2"]
    G["Web Application Pod"]
    H["Web Application Pod"]

    A --> B
    B --> C
    B --> D
    C --> E
    D --> F
    E --> G
    F --> H
```

## Planned Node Group Configuration

- Minimum nodes: 2
- Desired nodes: 2
- Maximum nodes: 3
- Subnets: Two private subnets in separate Availability Zones
- Node label: workload=web
- Instance type: t3.small (candidate for evaluation)

The control plane manages the Kubernetes cluster.
The managed node group provides EC2 worker capacity.
Application Pods run on the worker nodes.

Pod placement across nodes may require topology spread
constraints or Pod anti-affinity.
