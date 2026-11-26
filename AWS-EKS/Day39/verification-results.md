# Day 39 - IAM, Cluster Access and IRSA Verification

## Environment
- Local AWS emulator: Floci
- AWS endpoint: http://localhost:4566
- Region: us-east-1
- Kubernetes: K3s inside Docker
- Namespace: dev

## Task A - Kubernetes RBAC

Resources:
- Role: dev-pod-reader
- RoleBinding: dev-pod-reader-binding
- Group: dev-pod-readers

Verified authorization results:
- get pods: yes
- list pods: yes
- delete pods: no

Result: Least-privilege Pod read access verified.

## Task B - AWS IAM and EKS Inspection

- STS GetCallerIdentity: successful
- Simulated account ID: 000000000000
- IAM list-roles: no roles displayed
- IAM OIDC provider list: empty
- EKS list-clusters in us-east-1: empty

Note: The existing K3s container remained operational,
but Floci did not list the EKS cluster.

## Task C - IRSA Design

Kubernetes resources:
- ServiceAccount: dev/s3-reader-sa
- Pod: dev/s3-reader-demo
- IAM role annotation: present
- Pod ServiceAccount assignment: verified
- Standard Kubernetes token mount: verified

IAM policy templates:
- s3-reader-trust-policy.template.json
- s3-reader-permissions-policy.json

Both JSON files passed syntax validation.

## Task D - IRSA Verification

Findings:
- AWS_ROLE_ARN: not injected
- AWS_WEB_IDENTITY_TOKEN_FILE: not injected
- Separate AWS IRSA token volume: not found
- IAM role assumption: not verified
- S3 access: not verified

Conclusion:
Kubernetes ServiceAccount configuration was demonstrated.
End-to-end AWS IRSA was not established in the local
Floci/K3s environment.

## Security Lessons

1. Use least-privilege Kubernetes RBAC.
2. Separate Kubernetes authorization from AWS IAM.
3. Restrict IRSA trust to a specific ServiceAccount.
4. Use temporary AWS credentials instead of static keys.
5. Never treat an IAM role annotation alone as proof
   that IRSA is operational.
