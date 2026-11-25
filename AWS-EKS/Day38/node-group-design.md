
# Day 38 – AWS EKS Managed Node Group Design

## Scenario

Design a managed node group for a small stateless web application running across at least two EC2 worker nodes.

## Node Group Configuration

| Setting | Planned Value |
|---|---|
| Cluster | winter-arc-eks |
| Node Group | winter-arc-node-group |
| Instance Type | t3.small (candidate) |
| Minimum Nodes | 2 |
| Desired Nodes | 2 |
| Maximum Nodes | 3 |
| Disk Size | 20 GiB |
| Subnets | Two private subnets |
| Availability Zones | Two |
| Labels | workload=web |
| OS | EKS-optimized Linux |

## Why Private Subnets?

Worker nodes are commonly placed in private subnets to reduce direct internet exposure.

They can reach required AWS services through approved NAT Gateway routes or VPC endpoints, depending on the network design.

## Worker Node IAM Role

The EC2 node role grants permissions required for node operation.

Application Pods should use separate workload identities for their AWS permissions.

## Spare Capacity

The design allows scaling from two to three worker nodes.

This provides a possible additional node for updates or increased workload demand, subject to scaling configuration and instance availability.

## Cost and Safety

This is a design-only exercise.

No AWS EKS cluster or EC2 worker nodes have been created.

Before real provisioning, verify instance compatibility, EC2 pricing, subnet connectivity and budget approval.
