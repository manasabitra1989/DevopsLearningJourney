```markdown name=README.md
# Day 17 - Kubernetes Services & Networking

## Objective
Learn how Kubernetes Services provide stable networking for Pods and how to troubleshoot common Service issues.

## What I Did
- Created a Deployment with 3 replicas
- Exposed it using a ClusterIP Service
- Verified Service DNS resolution from inside the cluster
- Sent HTTP requests to the Service
- Deleted a Pod and observed it being replaced
- Broke the Service selector to test failure
- Restored the selector and verified connectivity again

## Setup
Check the cluster:

```bash
kubectl config current-context
kubectl get nodes
kubectl get deployments
kubectl get services
```

## Step 1: Create the app
```bash
kubectl create deployment hello --replicas=3 \
  --image=registry.k8s.io/e2e-test-images/agnhost:2.39 \
  -- /agnhost netexec --http-port=8080
```

Check pods:

```bash
kubectl get pods -l app=hello
kubectl rollout status deployment/hello
```

## Step 2: Create a Service
```bash
kubectl expose deployment hello --name=hello \
  --type=ClusterIP --port=80 --target-port=8080
```

Inspect the Service:

```bash
kubectl get svc hello -o wide
kubectl describe svc hello
kubectl get endpointslices -l kubernetes.io/service-name=hello -o wide
```

## Step 3: Test DNS from a temporary Pod
```bash
kubectl run tmp --rm -it \
  --image=busybox:1.36 \
  --restart=Never -- sh
```

Inside the Pod:

```sh
nslookup hello
nslookup hello.default.svc.cluster.local
wget -qO- http://hello/hostname
```

## Step 4: Check endpoints
```bash
kubectl get pods -l app=hello -o wide
kubectl get endpointslices -l kubernetes.io/service-name=hello -o wide
```

## Step 5: Delete a Pod
```bash
kubectl get pods -l app=hello
kubectl delete pod <pod-name>
kubectl get pods -l app=hello -w
```

Observe that Kubernetes creates a replacement pod and updates the Service endpoints.

## Step 6: Break the selector
```bash
kubectl patch service hello \
  -p '{"spec":{"selector":{"app":"hellow"}}}'
```

Check the Service:

```bash
kubectl describe service hello
kubectl get endpointslices -l kubernetes.io/service-name=hello -o wide
```

Expected result: no matching backend pods, so the Service has no working endpoints.

## Step 7: Fix the selector
```bash
kubectl patch service hello \
  -p '{"spec":{"selector":{"app":"hello"}}}'
```

Verify again:

```bash
kubectl get endpointslices -l kubernetes.io/service-name=hello -o wide
kubectl describe service hello
```

## Key Learnings
- A Service provides a stable DNS name and IP.
- Pods can change, but clients should use the Service name instead of Pod IPs.
- The Service selector must match Pod labels.
- EndpointSlices show the backend Pods for a Service.
- If a Service has no endpoints, traffic cannot reach the app.
- `port` is the Service port and `targetPort` is the app port.

## Troubleshooting
If the Service does not work, check:
- Pod labels
- Service selector
- EndpointSlices
- Pod readiness
- `targetPort` value
- CoreDNS resolution

## Cleanup
```bash
kubectl delete service hello
kubectl delete deployment hello
kubectl get deployments
kubectl get services
kubectl get pods
```

## Final Summary
This lab taught me how Kubernetes Services route traffic to Pods, how DNS resolves Service names, and how incorrect selectors can break connectivity. Services are essential for stable internal communication in Kubernetes.
```
