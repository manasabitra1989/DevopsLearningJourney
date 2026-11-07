# Day 20 — Kubernetes Health Checks, Resources & Autoscaling

**DevOps Winter Arc | 90 Days Challenge | Kubernetes Week 3**

## Objective

Configure a PHP Apache application with startup, readiness and liveness probes; define CPU and memory requests/limits; inspect Quality of Service (QoS); and use a Horizontal Pod Autoscaler (HPA) to scale between **1 and 5 replicas** based on CPU utilization.

## Lab environment

- Local **kind** cluster: `kind-winter-arc`
- Kubernetes: `v1.31.0`
- Node: `winter-arc-control-plane` (Debian 12 on WSL2)
- Namespace: `day20-health`
- Application: `registry.k8s.io/hpa-example` (`php-apache`)

## 1. Check metrics and install Metrics Server

```bash
kubectl config current-context
kubectl get nodes -o wide
kubectl get pods -n kube-system
kubectl top nodes
```

Initially, `kubectl top nodes` returned `Metrics API not available`. Install Metrics Server:

```bash
kubectl apply -f https://github.com/kubernetes-sigs/metrics-server/releases/latest/download/components.yaml

# Local kind lab only: bypass kubelet certificate verification
kubectl patch deployment metrics-server -n kube-system --type=json \
  -p='[{"op":"add","path":"/spec/template/spec/containers/0/args/-","value":"--kubelet-insecure-tls"}]'

kubectl rollout status deployment/metrics-server -n kube-system
kubectl top nodes
kubectl top pods -A
```

**Observed:** Metrics Server rolled out successfully. Node CPU: `159m (3%)`; memory: `965Mi (25%)` at the time of verification. Do not use `--kubelet-insecure-tls` indiscriminately in production.

![Metrics Server verification](screenshots/01-metrics-server.png)

## 2. Deploy PHP Apache with health probes and resources

```bash
kubectl create namespace day20-health
kubectl apply -f deployment.yaml
kubectl rollout status deployment/php-apache -n day20-health
kubectl get pods -n day20-health
kubectl describe pod -n day20-health -l app=php-apache
```

`deployment.yaml`:

```yaml
apiVersion: apps/v1
kind: Deployment
metadata:
  name: php-apache
  namespace: day20-health
spec:
  replicas: 1
  selector:
    matchLabels:
      app: php-apache
  template:
    metadata:
      labels:
        app: php-apache
    spec:
      containers:
        - name: php-apache
          image: registry.k8s.io/hpa-example
          ports:
            - containerPort: 80
          resources:
            requests:
              cpu: 200m
              memory: 64Mi
            limits:
              cpu: 500m
              memory: 128Mi
          startupProbe:
            httpGet:
              path: /
              port: 80
            failureThreshold: 30
            periodSeconds: 2
          readinessProbe:
            httpGet:
              path: /
              port: 80
            initialDelaySeconds: 5
            periodSeconds: 5
          livenessProbe:
            httpGet:
              path: /
              port: 80
            initialDelaySeconds: 15
            periodSeconds: 10
```

| Probe | Purpose | Failure behavior |
|---|---|---|
| Startup | Give the application time to initialize | Repeated failures restart the container |
| Readiness | Decide whether the Pod should receive Service traffic | Marks Pod NotReady; does not itself restart the container |
| Liveness | Detect a stuck/unhealthy container | Repeated failures restart the container |

**Observed:** The application Pod was `1/1 Running`, `Ready=True`, with `0` restarts. All three probes were configured.

![Pod resources and probes](screenshots/02-pod-resources.png)

## 3. Inspect resource usage and QoS

```bash
kubectl get pod -n day20-health -l app=php-apache \
  -o jsonpath='{.items[0].status.qosClass}'
echo
kubectl top pods -n day20-health
kubectl describe pod -n day20-health -l app=php-apache
```

| Resource | Request | Limit | Observed usage |
|---|---:|---:|---:|
| CPU | 200m | 500m | 21m |
| Memory | 64Mi | 128Mi | 12Mi |

**Observed QoS:** `Burstable`, because CPU/memory requests and limits are defined but not equal. Other QoS classes are `Guaranteed` and `BestEffort`.

![QoS and resource usage](screenshots/03-qos-burstable.png)

## 4. Configure the Horizontal Pod Autoscaler

```bash
kubectl autoscale deployment php-apache -n day20-health \
  --cpu-percent=50 --min=1 --max=5
kubectl get hpa -n day20-health
kubectl describe hpa php-apache -n day20-health
```

HPA uses **CPU utilization relative to the requested CPU**. With a `200m` CPU request, a `50%` target corresponds to approximately `100m` average CPU usage per Pod.

**Observed before load:** `cpu: 15%/50%`, `MINPODS=1`, `MAXPODS=5`, `REPLICAS=1`.

![HPA before load](screenshots/04-hpa-before.png)

## 5. Create a Service and generate load

The load-generator command accesses the application's Kubernetes Service DNS name, so a Service is required:

```bash
kubectl expose deployment php-apache -n day20-health \
  --name=php-apache --port=80 --target-port=80
kubectl get svc -n day20-health
```

**Terminal 1 — load generator:**

```bash
kubectl run load-generator -n day20-health \
  --image=busybox:1.36 --restart=Never -it --rm -- \
  /bin/sh -c "while true; do wget -q -O- http://php-apache.day20-health.svc.cluster.local; done"
```

**Terminal 2 — watch HPA:**

```bash
kubectl get hpa -n day20-health -w
```

**Terminal 3 — watch Pods:**

```bash
kubectl get pods -n day20-health -w
kubectl top pods -n day20-health
```

**Observed:** HPA increased replicas from **1 to 5**. All **5/5** PHP Apache Pods were `1/1 Running` with **0 restarts**. The later HPA reading was `cpu: 15%/50%` with 5 replicas, illustrating that the current utilization and replica count do not necessarily change simultaneously.

![HPA scaling](screenshots/05-hpa-scaling.png)

![Five running Pods](screenshots/06-pods-scaled.png)

### Observe scale-down

Stop the load generator with `Ctrl+C`, then watch:

```bash
kubectl get hpa -n day20-health -w
kubectl get pods -n day20-health -w
kubectl describe hpa php-apache -n day20-health
```

**Observed so far:** CPU readings fell to `17%`, `14%` and `16%` while replicas remained at 5. HPA scale-down can be delayed by its stabilization window. **Final return to 1 replica was not yet confirmed** in the shared terminal output.

<!-- Add a scale-down screenshot after verifying the replica count has decreased. -->

## 6. Readiness probe failure and recovery (practice procedure)

> **Status:** Procedure prepared; successful failure and recovery have not yet been verified from terminal output.

Edit `deployment.yaml` and temporarily change only the readiness probe's `path: /` to `path: /invalid`. Do **not** change startup or liveness paths.

```bash
kubectl apply -f deployment.yaml
kubectl get pods -n day20-health -w
kubectl describe pod -n day20-health -l app=php-apache
kubectl get events -n day20-health --sort-by=.lastTimestamp
```

**Expected:** A newly rolled-out Pod may show `0/1 Running` and a readiness failure (typically HTTP 404). Because the Deployment uses a rolling update, an older healthy Pod may remain available while the replacement is NotReady.

Restore the readiness path to `/`, then:

```bash
kubectl apply -f deployment.yaml
kubectl rollout status deployment/php-apache -n day20-health
kubectl get pods -n day20-health
```

<!-- After successful verification, add screenshots of the failure and recovery here. -->

## Troubleshooting reference

| Symptom | Check |
|---|---|
| `Metrics API not available` | Metrics Server rollout, Pods, logs and API availability |
| HPA shows unknown CPU | Metrics Server and container CPU requests |
| HPA does not scale up | Current CPU, target, max replicas, load and events |
| Pod NotReady | Readiness path/port, `kubectl describe pod`, events |
| Container restarts | Liveness/startup probes, events, container logs |
| `OOMKilled` | Memory usage and configured limits |
| New Pods Pending | Node capacity and Pod resource requests |

## Key takeaways

1. **Readiness** controls traffic eligibility; **liveness** can restart an unhealthy container; **startup** protects slow-starting applications.
2. CPU/memory **requests** inform scheduling, while **limits** constrain resource usage.
3. The Pod's **QoS** class is `Burstable`.
4. **Metrics Server** supplies resource metrics used by `kubectl top` and HPA.
5. **HPA** can increase and decrease replicas automatically, subject to configured bounds, observed metrics, stabilization, and node capacity.
6. Autoscaling does not guarantee better performance when bottlenecks are elsewhere.

## Cleanup (after capturing screenshots)

```bash
kubectl delete namespace day20-health
```

Keep Metrics Server installed if needed for future labs.

---

**Challenge:** DevOps Winter Arc — Day 20  
**Topic:** Kubernetes Health, Resources & Autoscaling
