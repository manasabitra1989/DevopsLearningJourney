# Day 15: Kubernetes Fundamentals

## Objective
Understand how Kubernetes runs containerized applications, deploy an Nginx application to a local cluster using declarative YAML manifests, verify workload health, scale replicas, expose the workload via a NodePort Service, demonstrate controller-level self-healing, and document troubleshooting observations.

---

## Architecture and Core Concepts

| Concept | Definition & Purpose | Implementation in Today's Lab |
| :--- | :--- | :--- |
| **Docker vs. Kubernetes** | Docker builds, packages, and runs container images on a single host. Kubernetes is an orchestration engine that manages container lifecycles, automated multi-node scheduling, scaling, and fault tolerance across a cluster. | Docker engine hosts the `kind` nodes; Kubernetes orchestrates Nginx instances. |
| **Cluster** | The entire operational Kubernetes compute system made up of control plane components and worker nodes. | The local single-node cluster named `winter-arc`. |
| **Control Plane** | The master coordination layer (API server, scheduler, controller manager, etcd) responsible for maintaining the desired cluster state. | Coordinates and reconciles the declared manifests against running resources. |
| **Worker Node** | A virtual or physical compute machine running `kubelet`, `containerd`, and `kube-proxy` to host application Pods. | The `winter-arc-control-plane` node executing the container workloads. |
| **Pod** | The atomic deployable computing unit in Kubernetes, grouping one or more containers sharing network namespaces and storage. | Pods running the `nginx:1.27` container instance. |
| **Deployment** | A declarative controller managing ReplicaSets to provide automated self-healing, rolling updates, and replica tracking. | `nginx-deployment` managing desired Nginx replicas (initially 2, then 3). |
| **Service** | A persistent network abstraction and load balancer providing a stable IP and port mapping across ephemeral Pod instances. | `nginx-service` configured as `NodePort` with static target mapping. |

---

## Local Cluster Setup

The local cluster was initialized using `kind` (Kubernetes in Docker):

```bash
# Provision cluster
kind create cluster --name winter-arc

# Verify cluster connectivity and node state
kubectl cluster-info
kubectl get nodes
```

**Verification:**
The command `kubectl get nodes` confirmed that `winter-arc-control-plane` transitioned to the `Ready` status.

---

## Deployment and Service Manifests

### 1. Deployment Manifest (`deployment.yaml`)
```yaml
apiVersion: apps/v1
kind: Deployment
metadata:
  name: nginx-deployment
  labels:
    app: nginx
spec:
  replicas: 2
  selector:
    matchLabels:
      app: nginx
  template:
    metadata:
      labels:
        app: nginx
    spec:
      containers:
      - name: nginx
        image: nginx:1.27
        ports:
        - containerPort: 80
```

### 2. Service Manifest (`service.yaml`)
```yaml
apiVersion: v1
kind: Service
metadata:
  name: nginx-service
spec:
  type: NodePort
  selector:
    app: nginx
  ports:
    - port: 80
      targetPort: 80
      nodePort: 30080
```

---

## Execution and Verification Log

### Step 1: Resource Deployment
Applied both manifests to create the deployment and the service:
```bash
kubectl apply -f deployment.yaml
kubectl apply -f service.yaml

kubectl get deployments
kubectl get pods -o wide
kubectl get services
```
- **Result:** `nginx-deployment` reached `2/2` ready state. Two Pods entered `Running` state, and `nginx-service` was bound to NodePort `30080`.

### Step 2: Scaling Replicas
Scaled the deployment to 3 replicas as required by the assignment:
```bash
kubectl scale deployment nginx-deployment --replicas=3
kubectl get deployment nginx-deployment
kubectl get pods
```
- **Result:** The deployment reported `3/3` ready replicas, with three unique Pods running across the cluster.

### Step 3: Application Access Verification
Because standard `kind` clusters isolate container ports from the host network stack unless custom port mapping configurations are added at cluster creation, port forwarding was used to establish direct access:
```bash
# Run in terminal session
kubectl port-forward service/nginx-service 8080:80
```
Verified connectivity via `curl` in a secondary terminal:
```bash
curl http://localhost:8080
```
- **Result:** Successfully received the default Nginx welcome page HTML (`<h1>Welcome to nginx!</h1>`).

---

## Troubleshooting & Self-Healing

### Controller Self-Healing Test
To verify the controller's reconciliation loop:
1. Listed active Pods using `kubectl get pods`.
2. Terminated one Pod:
   ```bash
   kubectl delete pod <target-pod-name>
   ```
3. Monitored recovery in real-time:
   ```bash
   kubectl get pods -w
   ```
- **Outcome:** The targeted Pod entered `Terminating`. The Deployment controller instantly detected that actual replicas ($2$) deviated from desired state ($3$) and created a new replacement Pod to restore the declared state.

### Diagnostic Tools Practiced
- `kubectl describe deployment nginx-deployment`: Inspected deployment rollout history, conditions, replica set mappings, and selector configurations.
- `kubectl describe service nginx-service`: Verified that `Endpoints` populated with the active internal IPs of the matching Nginx Pods.
- `kubectl get events --sort-by=.metadata.creationTimestamp`: Tracked cluster events to diagnose scheduling and container lifecycle transitions.

---

## Evidence Checklist

All screenshots are stored in the `evidence/` directory:
- `evidence/01-cluster-nodes.png`: Output of `kubectl cluster-info` and `kubectl get nodes` showing `Ready` status.
- `evidence/02-initial-deployment.png`: `kubectl get deployments,pods,services` showing initial 2 Pods and `nginx-service`.
- `evidence/03-scaled-three-replicas.png`: Terminal output showing all 3 Pods running after scaling.
- `evidence/04-curl-access-success.png`: Successful output of `curl http://localhost:8080` displaying Nginx HTML.
- `evidence/05-self-healing.png`: Terminal output demonstrating automatic recreation of a deleted Pod.

---

## Cleanup

To release resources after capturing verification evidence:
```bash
# Delete application workloads
kubectl delete -f service.yaml
kubectl delete -f deployment.yaml

# Tear down local cluster (optional if proceeding to Day 16)
# kind delete cluster --name winter-arc
```