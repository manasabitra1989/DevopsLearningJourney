# Day 16 - Kubernetes Deployments & Rollouts

## Synopsis

This lab focuses on understanding how Kubernetes Deployments manage application updates, rollout history, and rollback behavior. We deploy Nginx using a Deployment, perform a rolling update to a newer image version, observe rollout status, intentionally trigger a failed rollout using an invalid image tag, diagnose the failure, and restore the last known-good configuration using rollback.

The goal is to understand how Kubernetes transitions an application from one version to another while preserving availability and maintaining historical revisions.

---

## Objective

To learn how Kubernetes Deployments:

- manage replicas and Pod lifecycle
- perform rolling updates without replacing all Pods at once
- maintain revision history
- detect failed rollouts
- rollback to a previous healthy revision

---

## Technologies Used

- Kubernetes
- kubectl
- Docker Desktop / kind
- Nginx
- Deployment and ReplicaSet
- YAML

---

## Lab Flow

### 1. Verify cluster health
Check that the Kubernetes cluster is running and that the target Deployment exists.

```bash
kubectl config current-context
kubectl get nodes
kubectl get deployments
kubectl get pods
kubectl get rs
```

---

### 2. Inspect the current Deployment
Review the Deployment configuration and record the current image.

```bash
kubectl describe deployment nginx-deployment
kubectl get deployment nginx-deployment -o yaml
kubectl get deployment nginx-deployment -o jsonpath='{.spec.template.spec.containers[0].image}'; echo
```

---

### 3. Perform a rolling update
Update the Nginx image from the current version to a newer version.

```bash
kubectl set image deployment/nginx-deployment nginx=nginx:1.28
kubectl rollout status deployment/nginx-deployment
kubectl rollout history deployment/nginx-deployment
```

This creates a new revision and gradually updates Pods.

---

### 4. Understand rollout strategy
Check and configure rolling update settings such as:

```yaml
strategy:
  type: RollingUpdate
  rollingUpdate:
    maxSurge: 1
    maxUnavailable: 0
```

This helps control how many Pods can be replaced during the update.

---

### 5. Trigger a failed rollout
Intentionally set an invalid image tag to simulate a broken deployment.

```bash
kubectl set image deployment/nginx-deployment nginx=nginx:1.99-broken
kubectl rollout status deployment/nginx-deployment --timeout=60s
kubectl get pods
kubectl get rs
```

This should result in a failure because Kubernetes cannot pull the invalid image.

---

### 6. Diagnose the failure
Inspect the failing Pod and review Events to identify the problem.

```bash
kubectl get pods
kubectl describe pod POD_NAME
kubectl get events --sort-by=.metadata.creationTimestamp
kubectl describe deployment nginx-deployment
```

Common errors include:

- `ErrImagePull`
- `ImagePullBackOff`
- image not found

---

### 7. Roll back to the previous working state
Restore the last known-good Deployment revision.

```bash
kubectl rollout undo deployment/nginx-deployment
kubectl rollout status deployment/nginx-deployment --timeout=120s
```

Verify that the Deployment is restored to the working image.

```bash
kubectl get deployment nginx-deployment -o jsonpath='{.spec.template.spec.containers[0].image}'; echo
kubectl get pods
kubectl get rs
```

---

## Expected Outcome

By the end of the lab:

- the Deployment updates successfully
- rollout history is available
- an invalid image produces a rollout failure
- the failure is diagnosed using Pod and Event details
- the app is restored to the last healthy revision using rollback

---

## Evidence to Capture

Take screenshots or save terminal output for:

- initial Deployment state
- successful rolling update
- rollout history
- failed rollout
- image-pull failure
- rollback verification

Suggested filenames:

```text
evidence/
├── 01-initial-deployment.png
├── 02-successful-rolling-update.png
├── 03-rollout-history.png
├── 04-failed-rollout.png
├── 05-image-pull-events.png
└── 06-rollback-verified.png
```

---

## Key Learning Outcomes

- Kubernetes Deployments manage application version changes safely
- Rolling updates replace Pods gradually instead of all at once
- ReplicaSets track old and new Pod states
- Failed rollouts can be diagnosed using Pod details and Events
- Rollback helps restore a previously healthy Deployment revision

---

## Cleanup

If you no longer need the lab resources:

```bash
kubectl delete deployment nginx-deployment
kubectl delete service nginx-service
```

Only delete resources that belong to this lab and are no longer needed.

---

## Final Note

This lab demonstrates how Kubernetes handles deployment updates, rollout failures, and recovery. It highlights the importance of revision history and rollback in maintaining healthy application delivery.
