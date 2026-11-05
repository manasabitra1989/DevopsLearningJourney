# Day 18 – Kubernetes ConfigMaps, Secrets & Namespaces

**DevOps Winter Arc – 90 Days Challenge**

## Objective

Run the same Nginx application in two isolated Kubernetes namespaces (`dev` and `prod`), while supplying different configuration and webpage content through namespace-specific ConfigMaps and Secrets.

## Concepts Practiced

- **Namespaces:** Logical separation of development and production resources in one cluster.
- **ConfigMaps:** Store non-sensitive configuration such as `APP_ENV` and `index.html`.
- **Secrets:** Store sensitive configuration separately from application manifests. This lab uses **dummy passwords only**.
- **Environment variables:** Inject configuration into a container when it starts.
- **ConfigMap volumes:** Mount configuration as files inside a container.

## Project Structure

```text
Day18/
├── README.md
├── configmap-dev.yaml
├── configmap-prod.yaml
├── deployment.yaml
└── screenshots/                 # Optional: add your evidence images here
```

> Adjust screenshot paths and filenames to match your repository. Do not commit real passwords or credential files.

## Task A – Create Namespaces

```bash
kubectl create namespace dev
kubectl create namespace prod
kubectl get namespaces
```

If a namespace already exists, inspect it instead of deleting it.

## Task B – Create ConfigMaps

Create `configmap-dev.yaml`:

```yaml
apiVersion: v1
kind: ConfigMap
metadata:
  name: site
data:
  APP_ENV: dev
  index.html: |
    <h1>Hello from DEV</h1>
    <p>Winter Arc · Day 4</p>
```

Create `configmap-prod.yaml`:

```yaml
apiVersion: v1
kind: ConfigMap
metadata:
  name: site
data:
  APP_ENV: prod
  index.html: |
    <h1>Hello from PROD</h1>
    <p>Winter Arc · Day 4</p>
```

Apply each ConfigMap to its own namespace:

```bash
kubectl apply -f configmap-dev.yaml -n dev
kubectl apply -f configmap-prod.yaml -n prod
kubectl get configmap site -n dev
kubectl get configmap site -n prod
```

Both resources are named `site`, but they are separate objects because they exist in different namespaces.

## Task C – Create Dummy Secrets

```bash
kubectl create secret generic db-secret --from-literal=password=dev-pass -n dev
kubectl create secret generic db-secret --from-literal=password=prod-pass -n prod
kubectl get secret db-secret -n dev
kubectl get secret db-secret -n prod
```

These are **lab-only example passwords**. Never commit real credentials to GitHub. Base64 encoding in Kubernetes Secret manifests is not encryption.

## Task D – Deploy the Same Nginx Workload to Both Namespaces

Create `deployment.yaml`:

```yaml
apiVersion: apps/v1
kind: Deployment
metadata:
  name: web
spec:
  replicas: 1
  selector:
    matchLabels:
      app: web
  template:
    metadata:
      labels:
        app: web
    spec:
      containers:
        - name: nginx
          image: nginx:1.27
          ports:
            - containerPort: 80
          env:
            - name: APP_ENV
              valueFrom:
                configMapKeyRef:
                  name: site
                  key: APP_ENV
            - name: DB_PASSWORD
              valueFrom:
                secretKeyRef:
                  name: db-secret
                  key: password
          volumeMounts:
            - name: html
              mountPath: /usr/share/nginx/html
      volumes:
        - name: html
          configMap:
            name: site
```

Deploy the same manifest twice:

```bash
kubectl apply -f deployment.yaml -n dev
kubectl apply -f deployment.yaml -n prod
kubectl get pods -n dev
kubectl get pods -n prod
```

Nginx serves `index.html` from the mounted ConfigMap. `APP_ENV` is also injected as an environment variable. `DB_PASSWORD` is available to the container but is not used by the default Nginx page.

## Task E – Verify DEV and PROD

In **Terminal 1**:

```bash
kubectl port-forward -n dev deploy/web 8081:80
```

In **Terminal 2**:

```bash
kubectl port-forward -n prod deploy/web 8082:80
```

In **Terminal 3**:

```bash
curl http://localhost:8081
curl http://localhost:8082
kubectl exec -n dev deploy/web -- printenv APP_ENV
kubectl exec -n prod deploy/web -- printenv APP_ENV
```

Expected page headings and environment values:

| Namespace | URL | Expected heading | `APP_ENV` |
|---|---|---|---|
| `dev` | `http://localhost:8081` | `Hello from DEV` | `dev` |
| `prod` | `http://localhost:8082` | `Hello from PROD` | `prod` |

Verify that the Secret environment variable exists **without printing its value**:

```bash
kubectl exec -n dev deploy/web -- sh -c 'test -n "$DB_PASSWORD" && echo "DB_PASSWORD is set"'
kubectl exec -n prod deploy/web -- sh -c 'test -n "$DB_PASSWORD" && echo "DB_PASSWORD is set"'
```

> `localhost` refers to the computer where `kubectl port-forward` is running. If you run it inside a remote VM, access it from that environment or configure an appropriate forwarding path.

## Task F – Update the DEV ConfigMap

Edit the DEV ConfigMap:

```bash
kubectl edit configmap site -n dev
```

Change `APP_ENV` to `dev-updated` and the page heading to `Hello from UPDATED DEV`.

After a short delay, the mounted `index.html` file should reflect the new ConfigMap content, but an already-running container's environment variable will still contain the original value.

```bash
curl http://localhost:8081
kubectl exec -n dev deploy/web -- printenv APP_ENV
```

Restart the DEV Deployment to refresh environment variables:

```bash
kubectl rollout restart deployment/web -n dev
kubectl rollout status deployment/web -n dev
kubectl exec -n dev deploy/web -- printenv APP_ENV
```

Expected `APP_ENV` after restart: `dev-updated`. The PROD ConfigMap and Deployment remain unchanged.

> ConfigMap volume updates are eventually reflected in mounted files (typically after a short delay); environment variables are resolved when the container starts. A `subPath` ConfigMap mount does not receive automatic updates.

## Troubleshooting

| Issue | What to check |
|---|---|
| `CreateContainerConfigError` | Confirm `site`, `db-secret`, and their referenced keys exist in the **same namespace** as the Pod. |
| Wrong webpage content | Check the namespace, `index.html` ConfigMap key, and mount path `/usr/share/nginx/html`. |
| `APP_ENV` does not change after editing ConfigMap | Restart the Deployment; environment variables do not refresh inside existing containers. |
| `curl localhost:8081` fails | Confirm the DEV port-forward is still running and that you are accessing it from the correct machine. |

Useful diagnostics:

```bash
kubectl describe pod -n dev <pod-name>
kubectl get configmap site -n dev -o yaml
kubectl get secret db-secret -n dev
kubectl get deployment web -n dev
```

## Reflection Questions and Answers

**1. What is the difference between a ConfigMap and a Secret?**  
A ConfigMap stores non-sensitive configuration; a Secret is intended for sensitive values such as passwords and tokens. Secret data requires appropriate access controls and security configuration.

**2. Why must the ConfigMap and Secret be in the same namespace as the Pod?**  
A Pod references ConfigMaps and Secrets within its own namespace; it cannot directly use a same-named resource from another namespace.

**3. How do environment variables differ from mounted configuration files?**  
Environment variables are set when the container starts. ConfigMap-mounted files can update while the Pod continues running.

**4. Why does changing a ConfigMap not update an existing environment variable?**  
The container's environment is initialized at startup. Restart the Pod or Deployment to load the new value.

**5. Why is base64 encoding not enough to secure Secrets?**  
Base64 is reversible encoding, not encryption. Use RBAC, encryption at rest, and appropriate secret-management practices.

**6. What can cause `CreateContainerConfigError`?**  
A missing ConfigMap, Secret, or required key referenced by the Pod, among other container configuration problems. Check Pod events using `kubectl describe pod`.

**7. How do namespaces help separate DEV and PROD?**  
Namespaces provide separate names and scopes for Kubernetes resources, allowing the same Deployment and ConfigMap names to exist with different configurations. They are not, by themselves, a complete security boundary.

## Evidence / Screenshots

Add screenshots showing:

- DEV and PROD namespaces
- DEV and PROD ConfigMaps
- DEV and PROD Secret resource existence (do not expose values)
- Pods running in both namespaces
- Different DEV and PROD webpage output
- `APP_ENV` values in both namespaces
- DEV page update and `APP_ENV` after Deployment restart

## Key Takeaways

- One Kubernetes Deployment manifest can be reused across environments.
- Namespace-specific ConfigMaps and Secrets provide different settings for the same application image.
- ConfigMap volume files can refresh without a Pod restart, while environment variables require a restart.
- Secrets should be handled carefully and never exposed in public repositories.

## Optional Cleanup

**Only if `dev` and `prod` were created exclusively for this lab**, and after collecting evidence:

```bash
kubectl delete namespace dev
kubectl delete namespace prod
```

Deleting a namespace removes all resources inside it.
