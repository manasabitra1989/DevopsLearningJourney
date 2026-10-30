# Day 14: Docker in CI/CD Pipeline



**DevOps Winter Arc | Week 2: Docker | Build • Test • Scan • Publish • Deploy**

---

## 📌 Pipeline Flowchart



```text
[Developer Push / PR]
         │
         ▼
 1. Lint Dockerfile (Hadolint)
         │
         ▼
 2. Build Container Image (Buildx / GHA Cache)
         │
         ▼
 3. Smoke Test (/health Endpoint Check)
         │
         ▼
 4. Trivy Vulnerability Scan (Gating: Fail on HIGH/CRITICAL)
         │
         ▼
 5. Publish to Registry (Docker Hub) ───► Tagged with Immutable Git Commit SHA

```



---

## 🛡️ Security & Registry Configuration



* **Immutable Tags**: Images are tagged strictly with the full commit SHA (`${{ github.sha }}`) to guarantee traceability and enable safe rollbacks.


* **Pipeline Gates**: The pipeline terminates immediately if Hadolint fails, the `/health` endpoint fails, or Trivy finds unfixed `HIGH` or `CRITICAL` vulnerabilities.


* **Least-Privilege Secrets**: Docker Hub credentials are held securely in GitHub Secrets (`DOCKERHUB_USERNAME`, `DOCKERHUB_TOKEN`) and publishing only executes on verified pushes to the `main` branch.



---

## 📂 Repository Structure



```text
day14-docker-cicd/
├── .dockerignore
├── .gitignore
├── .github/
│   └── workflows/
│       └── docker-ci.yml
├── Dockerfile
├── README.md
├── app.py
├── requirements.txt
└── evidence/
    ├── pipeline-success.png
    ├── dockerhub-sha-tag.png
    └── rollback-verification.png

```



---

## 🔄 Deployment & Rollback Procedure



### Deploying the Release:



```bash
# Retrieve full commit SHA[cite: 3, 6]
COMMIT_SHA=$(git rev-parse HEAD)[cite: 3, 6]

# Pull and run the immutable image[cite: 3, 6]
docker pull <DOCKERHUB_USERNAME>/winter-arc-app:$COMMIT_SHA[cite: 6]
docker run -d --name winter-app -p 5000:5000 --restart unless-stopped <DOCKERHUB_USERNAME>/winter-arc-app:$COMMIT_SHA[cite: 6, 7]
curl -f http://localhost:5000/health[cite: 3, 6]

```

### Emergency Rollback:



If an issue occurs in production, immediately roll back to the previously verified, known-good commit SHA:

```bash
# Set known-good SHA[cite: 6]
PREV_SHA="<INSERT_PREVIOUS_GOOD_SHA>"[cite: 6]

# Stop and remove the active container[cite: 6]
docker rm -f winter-app || true[cite: 6]

# Deploy previous known-good image[cite: 6, 8]
docker pull <DOCKERHUB_USERNAME>/winter-arc-app:$PREV_SHA[cite: 6]
docker run -d --name winter-app -p 5000:5000 --restart unless-stopped <DOCKERHUB_USERNAME>/winter-arc-app:$PREV_SHA[cite: 6, 7]

# Verify service health[cite: 6]
curl -f http://localhost:5000/health[cite: 3, 6]

```
