# Day 21/90 — Kubernetes Security, RBAC & Troubleshooting ☸️

## Objective

Implement namespace-scoped RBAC, secure Kubernetes workloads using Pod Security Standards and `securityContext`, and troubleshoot three intentionally broken Deployments.

## Environment

- Kubernetes: v1.31.0
- Cluster: `kind-winter-arc`
- Node: `winter-arc-control-plane`
- Operating System: Debian 12 on WSL2
- Container Runtime: containerd
- Namespaces: `secure`, `lab`

## Part 1 — Kubernetes RBAC

**RBAC (Role-Based Access Control)** determines who can perform which actions on Kubernetes resources.

### Components

| Component | Purpose |
|---|---|
| ServiceAccount | Identity for applications or tools |
| Role | Defines namespace-scoped permissions |
| RoleBinding | Assigns Role permissions to a subject |
| ClusterRole | Defines reusable or cluster-scoped permissions |
| ClusterRoleBinding | Grants permissions at cluster scope |

### Implementation

Created a `viewer` ServiceAccount in the `secure` namespace and assigned a `pod-reader` Role through the `viewer-pods` RoleBinding.

The Role permits `get`, `list`, and `watch` on `pods` and `pods/log`.

```bash
kubectl create namespace secure
kubectl create namespace lab
kubectl create serviceaccount viewer -n secure
kubectl apply -f rbac.yaml
```

### RBAC Verification

```bash
kubectl auth can-i get pods -n secure \
  --as=system:serviceaccount:secure:viewer

kubectl auth can-i delete pods -n secure \
  --as=system:serviceaccount:secure:viewer
```

Expected results:

| Action | Expected |
|---|---|
| Read Pods | yes |
| Delete Pods | no |
| Read Pod logs | yes |
| Read Pods in lab namespace | no |

**Learning:** RBAC implements least privilege by granting only the access required.

## Part 2 — Pod Security

### Pod Security Standards

Kubernetes defines three security profiles:

- **Privileged:** Unrestricted Pod configuration.
- **Baseline:** Prevents known privilege escalations.
- **Restricted:** Enforces stronger security requirements.

### Enforce Restricted Policy

```bash
kubectl label namespace secure \
  pod-security.kubernetes.io/enforce=restricted
```

### Secure Pod Configuration

The `secure-pod.yaml` file implements:

```yaml
securityContext:
  runAsNonRoot: true
  runAsUser: 10001
  seccompProfile:
    type: RuntimeDefault
```

Container-level settings include:

```yaml
securityContext:
  allowPrivilegeEscalation: false
  readOnlyRootFilesystem: true
  capabilities:
    drop: ["ALL"]
```

### Verification

```bash
kubectl apply -f secure-pod.yaml
kubectl get pods -n secure
kubectl exec -n secure secure-pod -- id
```

Expected result: The secure Pod is admitted and runs with a non-root UID.

### Negative Security Test

```bash
kubectl run root-pod --image=nginx:1.27 -n secure
```

Expected result: Kubernetes rejects the insecure Pod because it violates the restricted security policy.

**Learning:** Pod Security Admission can reject noncompliant workloads before scheduling.

## Part 3 — Kubernetes Troubleshooting

### Debugging Workflow

```text
get → describe → logs → events → exec
```

Collect evidence before modifying resources.

### Scenario 1 — ImagePullBackOff

**Symptom:** Kubernetes cannot pull the container image.

**Root cause:** Invalid image tag `nginx:1.99.99`.

```bash
kubectl create deployment broken1 -n lab \
  --image=nginx:1.99.99

kubectl describe pods -n lab -l app=broken1
```

**Fix:**

```bash
kubectl set image deployment/broken1 -n lab \
  nginx=nginx:1.27
```

### Scenario 2 — CrashLoopBackOff

**Symptom:** Container repeatedly terminates and restarts.

**Root cause:** Startup command deliberately exits with code 1.

```bash
kubectl create deployment broken2 -n lab \
  --image=busybox:1.36 -- sh -c "exit 1"

kubectl describe pods -n lab -l app=broken2
kubectl logs deployment/broken2 -n lab --previous
```

**Fix:** Replace the failing command with a long-running command for this lab.

```bash
kubectl patch deployment broken2 -n lab --type=strategic \
  -p '{"spec":{"template":{"spec":{"containers":[{"name":"busybox","command":["sh","-c","sleep 3600"],"args":[]}]}}}}'
```

### Scenario 3 — Pending Pod

**Symptom:** Pod cannot be scheduled.

**Root cause:** A 64Gi memory request exceeds the node's available allocatable resources.

```bash
kubectl create deployment broken3 -n lab \
  --image=nginx:1.27

kubectl set resources deployment/broken3 -n lab \
  --requests=memory=64Gi

kubectl describe pods -n lab -l app=broken3
```

**Fix:**

```bash
kubectl set resources deployment/broken3 -n lab \
  --requests=memory=64Mi
```

### Troubleshooting Summary

| Deployment | Symptom | Root Cause | Fix |
|---|---|---|---|
| broken1 | ImagePullBackOff | Invalid image tag | Corrected nginx image |
| broken2 | CrashLoopBackOff | Process exits with code 1 | Replaced startup command |
| broken3 | Pending | Excessive memory request | Reduced request to 64Mi |

## Final Verification

```bash
kubectl rollout status deployment/broken1 -n lab
kubectl rollout status deployment/broken2 -n lab
kubectl rollout status deployment/broken3 -n lab

kubectl get deployments,pods -n lab
kubectl get pods -n secure
```

Expected result: All three repaired Deployments have one available replica and their active Pods are Running.

## Evidence

Add screenshots to an `evidence/` folder:

1. `rbac-permissions.png` — Allowed and denied RBAC checks.
2. `pod-security-rejection.png` — Restricted policy rejection.
3. `deployments-recovered.png` — Three healthy Deployments and Pods.

## Key Takeaways

- RBAC controls access to Kubernetes resources.
- ServiceAccounts provide workload identities.
- Least privilege reduces unnecessary access.
- Pod Security Standards help enforce workload security.
- `securityContext` hardens container execution.
- Kubernetes Events and previous logs help identify failures.
- Resource requests influence Pod scheduling.
- Troubleshooting should be evidence-driven, with the smallest safe repair.


