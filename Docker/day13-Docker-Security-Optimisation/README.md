To give you a ready-to-use file, here is a complete, production-ready `README.md` template specifically tailored for your **Day 13: Docker Security & Optimization** assignment.

You can copy and paste this directly into your `day13-Docker-Security-Optimisation/README.md` file (make sure to update the placeholder numbers in the comparison table with your actual scan and size results):

```markdown
# Day 13: Docker Image Security & Hardening

**DevOps Winter Arc | Week 2: Docker | Learn • Scan • Fix • Prove**

---

## 📌 Executive Summary
This project demonstrates the security audit, remediation, and hardening of a containerized Python Flask web application. Starting from an intentionally insecure and bloated baseline image (`my-app:bad`), we remediate security antipatterns to produce an optimized, hardened version (`my-app:v2`). Security findings and image metrics are measured and validated before and after remediation using **Trivy**.

---

## 📊 Before vs. After Comparison Table

| Metric | `my-app:bad` (Vulnerable) | `my-app:v2` (Hardened) | Remediation Impact |
| :--- | :--- | :--- | :--- |
| **Base Image** | `python:latest` | `python:3.12-slim` | Pinned to a specific slim release; reduced attack surface. |
| **Image Size** | *(e.g., 1.02 GB)* | *(e.g., 148 MB)* | Multi-stage build and removal of unnecessary build tools. |
| **HIGH Vulnerabilities** | *(e.g., 42)* | *(e.g., 0)* | Removed extraneous packages (`build-essential`, `git`, `vim`). |
| **CRITICAL Vulnerabilities** | *(e.g., 11)* | *(e.g., 0)* | Base image updated and unneeded OS utilities eliminated. |
| **Runtime User** | `root` (UID 0) | `app` (UID 10001) | Principle of least privilege; prevents container breakout risks. |
| **Secret Handling** | Hardcoded `ENV API_TOKEN` | Runtime injection via `-e` | Zero credentials baked into image layers or history. |
| **Process Execution** | Shell form (`CMD python app.py`) | Exec form (`CMD ["python", "app.py"]`) | Direct signal propagation (SIGTERM) for graceful shutdowns. |

---

## 🛡️ Key Remediations Implemented

1. **Pinned & Slim Base Image**: 
   - Replaced the floating `python:latest` tag with `python:3.12-slim` to ensure predictable builds and avoid shipping thousands of unneeded system packages.
2. **Multi-Stage Build**:
   - Used an isolated `build` stage to compile dependencies via `pip install --prefix=/install`. Only the compiled packages were copied to the final runtime stage, leaving behind compilation tools (`gcc`, `make`).
3. **Non-Root User Execution**:
   - Created a dedicated system user `app` with `UID 10001` (`useradd -r -u 10001 app`) and instructed Docker to execute the container under this user (`USER app`).
4. **Secret Hygiene**:
   - Removed the hardcoded `ENV API_TOKEN` from the Dockerfile. Secrets are supplied dynamically at runtime using environment variables or secret files.
5. **Runtime Hardening Flags**:
   - The hardened container runs with the following runtime constraints:
     - `--read-only`: Enforces an immutable root filesystem.
     - `--tmpfs /tmp`: Allows temporary writes strictly in memory without modifying the root filesystem.
     - `--cap-drop ALL`: Drops all standard Linux kernel capabilities.
     - `--security-opt no-new-privileges`: Blocks child processes from gaining elevated permissions.
     - `--memory 256m --cpus 0.5 --pids-limit 100`: Prevents denial-of-service (DoS) or fork-bomb attacks from starving host resources.

---

## 🚀 Reproduction & Verification Steps

### 1. Build and Scan Baseline Image
```bash
# Build vulnerable baseline
docker build -f Dockerfile.bad -t my-app:bad .

# Inspect layer history for exposed secrets
docker history --no-trunc my-app:bad

# Save baseline Trivy scan report
mkdir -p reports
trivy image --severity HIGH,CRITICAL -f json -o reports/before.json my-app:bad
trivy image --severity HIGH,CRITICAL my-app:bad

```

### 2. Build and Scan Hardened Image

```bash
# Build hardened image without cache
docker build --pull --no-cache -f Dockerfile.good -t my-app:v2 .

# Verify image history contains no secrets
docker history --no-trunc my-app:v2

# Save hardened Trivy scan report
trivy image --severity HIGH,CRITICAL -f json -o reports/after.json my-app:v2
trivy image --severity HIGH,CRITICAL my-app:v2

# CI-gate simulation (fails build if actionable vulnerabilities exist)
trivy image --exit-code 1 --severity HIGH,CRITICAL --ignore-unfixed my-app:v2

```

### 3. Verify Non-Root Execution

```bash
# Verify user ID inside container
docker run --rm --entrypoint id my-app:v2
# Output: uid=10001(app) gid=10001(app)

# Verify image configuration metadata
docker image inspect my-app:v2 --format '{{.Config.User}}'

```

### 4. Run Container with Strict Security Restrictions

```bash
# Create local fake token (strictly excluded from Git via .gitignore)
printf 'training-token-only' > token.txt
chmod 600 token.txt

# Run hardened container
docker run -d --name safe \
  -p 127.0.0.1:5000:5000 \
  --memory 256m \
  --cpus 0.5 \
  --pids-limit 100 \
  --read-only \
  --tmpfs /tmp \
  --cap-drop ALL \
  --security-opt no-new-privileges \
  -e APP_ENV=lab \
  -e API_TOKEN="$(cat token.txt)" \
  my-app:v2

# Test endpoints
curl [http://127.0.0.1:5000/](http://127.0.0.1:5000/)
curl [http://127.0.0.1:5000/health](http://127.0.0.1:5000/health)

# Verify container runtime constraints
docker inspect safe --format 'ReadOnlyRootfs: {{.HostConfig.ReadonlyRootfs}}'
docker inspect safe --format 'CapDrop: {{.HostConfig.CapDrop}}'
docker inspect safe --format 'SecurityOpt: {{.HostConfig.SecurityOpt}}'

# Cleanup runtime container and local token
docker rm -f safe
rm -f token.txt

```

---

## 📂 Repository Structure

```text
.
├── .dockerignore              # Prevents secrets and caches from entering build context
├── .gitignore                 # Excludes local tokens and credentials from Git
├── Dockerfile.bad             # Deliberately insecure baseline Dockerfile
├── Dockerfile.good            # Hardened, multi-stage, non-root Dockerfile
├── README.md                  # Comprehensive security documentation
├── app.py                     # Flask web application
├── requirements.txt           # Pinned Python dependencies
├── reports/
│   ├── before.json            # Trivy scan results for my-app:bad
│   └── after.json             # Trivy scan results for my-app:v2
└── evidence/
    ├── scan-before.png        # Screenshot of baseline vulnerability scan
    ├── scan-after.png         # Screenshot of hardened vulnerability scan
    └── hardened-container.png # Screenshot of running container & inspect output

```

```

### Quick Instructions to Save It:
1. Inside your `Docker/day13-Docker-Security-Optimisation` directory, run:
   ```bash
   code README.md

```

2. Paste the text above, insert your exact numbers in the comparison table, and save (`Ctrl + S`).
