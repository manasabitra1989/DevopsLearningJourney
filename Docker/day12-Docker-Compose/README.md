For your Day 12 Docker Compose assignment, here is a complete, production-ready `README.md` formatted to satisfy all grading criteria and reflection questions from your assignment PDF.

To create it directly in your `day5-compose/` directory, run this command in your terminal:

```bash
cat << 'EOF' > README.md
# Day 12: Multi-Container Architecture with Docker Compose

## 📌 Project Overview
This project demonstrates orchestrating a multi-container microservice application using Docker Compose. The stack consists of a Flask web application, a PostgreSQL relational database for persistent visit logging, and a Redis in-memory cache for fast hit counting.

The implementation focuses on declarative infrastructure, service dependency sequencing with health checks, safe environment variable separation, data persistence across container lifecycles via named volumes, and container recovery using restart policies.

---

## 🏗 Architecture & Service Communication


```

```
           +---------------------------------------+
           |             Host Machine              |
           |         (Browser / curl: 5000)        |
           +-------------------+-------------------+
                               | :5000
                               v

```

+----------------------------------+-----------------------------------+
| Docker Project Network (bridge)                                     |
|                                                                     |
|    +-----------------------------------------------------------+    |
|    |                      web (Flask App)                      |    |
|    |                   Container Port: 5000                    |    |
|    +-----------------------------+-----------------------------+    |
|                                  |                                  |
|                 DB_HOST="db"     |     REDIS_HOST="redis"           |
|                +-----------------+-----------------+                |
|                v                                   v                |
|    +-----------------------+           +-----------------------+    |
|    |     db (Postgres)     |           |     redis (Redis)     |    |
|    |      Port: 5432       |           |      Port: 6379       |    |
|    +-----------+-----------+           +-----------------------+    |
|                |                                                    |
|                v                                                    |
|     +--------------------+                                          |
|     |   pgdata volume    | (Survives down/up)                       |
|     +--------------------+                                          |
+---------------------------------------------------------------------+

```

### Services Breakdown
1. **`web`**: Python 3.12-slim container running Flask on port 5000. It increments the counter in Redis, inserts a timestamped visit record into PostgreSQL, and exposes an HTTP `/health` check. Runs under a non-root `appuser`.
2. **`db`**: PostgreSQL 16 Alpine container storing visit records persistently via a named volume (`pgdata`).
3. **`redis`**: Redis 7 Alpine in-memory key-value store maintaining ephemeral request tallies.

---

## 📂 Directory Structure

```text
day5-compose/
├── compose.yaml          # Master Compose configuration
├── .env                  # Local secrets (ignored by Git)
├── .env.example          # Safe credential template (committed)
├── .gitignore            # Git exclusion rules
├── README.md             # Project documentation
├── evidence/             # Validation screenshots
│   ├── compose-status.png
│   ├── app-response.png
│   ├── persistence-test.png
│   └── restart-test.png
└── app/
    ├── app.py           # Application logic with DB retry loop
    ├── Dockerfile       # Multi-stage/secure non-root image build
    └── requirements.txt # Pinned Python dependencies

```

---

## 🚀 Quick Start Guide

### 1. Prerequisites

* Docker Engine 24.0+ and Docker Compose v2+ installed.

### 2. Setup Environment Configuration

Clone the repository and initialize the local `.env` file from the committed template:

```bash
cp .env.example .env

```

*(Optionally modify `.env` passwords for your local setup. Never commit `.env`.)*

### 3. Validate and Build Stack

```bash
# Validate Compose syntax and render configuration
docker compose config

# Build application image and start stack in detached mode
docker compose up -d --build

# Inspect container state and health status
docker compose ps

```

Wait until both `db` and `redis` report status `(healthy)` before testing endpoints.

---

## 🧪 Verification & Testing

### 1. Endpoint Testing & Counter Verification

Make repeated requests to verify that both Redis hits and PostgreSQL visits increment atomically:

```bash
# First request
curl http://localhost:5000/
# Output: Redis hits: 1 | Postgres visits: 1

# Second request
curl http://localhost:5000/
# Output: Redis hits: 2 | Postgres visits: 2

# Health endpoint verification
curl http://localhost:5000/health
# Output: ok

```

### 2. Proving Persistent Storage (Named Volumes)

Demonstrate that PostgreSQL data survives container destruction while ephemeral Redis memory resets:

```bash
# Teardown the containers and network (named volumes remain intact)
docker compose down

# Recreate the stack
docker compose up -d

# Verify state preservation
curl http://localhost:5000/
# Output: Redis hits: 1 | Postgres visits: 3

```

*Observation: `Postgres visits` continued from 3 because data is preserved on host-managed storage (`pgdata`). `Redis hits` reset to 1 because Redis has no volume configured.*

### 3. Verifying Self-Healing Restart Policy

Simulate a catastrophic container failure to verify `restart: unless-stopped`:

```bash
# Kill the running web service process
docker kill $(docker compose ps -q web)

# Inspect container status immediately
docker compose ps

# Re-test endpoint once revived
curl http://localhost:5000/

```

*Observation: The Docker engine detects the abrupt exit and automatically spins up a replacement container without human intervention.*

---

## 🔍 Production Debugging Guide

| Symptom | Root Cause | Remediation |
| --- | --- | --- |
| **Port 5000 already allocated** | Another process is binding `:5000` on the host. | Run `ss -lntp | grep 5000` or change port mapping to `"5001:5000"`. |
| **Database connection refused** | `web` tried connecting before Postgres initialized. | Check `condition: service_healthy` in `depends_on`, verify health check syntax. |
| **PostgreSQL data missing on restart** | Container created without named volume mount. | Confirm `pgdata` volume is declared globally and mounted at `/var/lib/postgresql/data`. |
| **Healthcheck syntax fails with empty user** | Variable interpolation occurred on host before container launch. | Use escaped `$$` syntax (`$${POSTGRES_USER}`) so expansion occurs inside the container shell. |
| **Code changes not reflected** | Docker cached previous image build layer. | Rebuild with `docker compose up -d --build`. |

---

## 💡 Concept Review & Architectural Reflection

### 1. How does `web` discover PostgreSQL and Redis?

Docker Compose creates a user-defined bridge network for the project. An embedded DNS resolver at `127.0.0.11` maps service names (`db`, `redis`) to their dynamic private container IP addresses. Inside container networks, `localhost` points strictly to the loopback interface of the current container.

### 2. Does `depends_on` guarantee database readiness?

No. By default, `depends_on` only tracks container startup (PID 1 creation), not whether the database daemon is ready to accept connections. Adding `condition: service_healthy` alongside container health checks ensures dependent services boot only after readiness probes pass.

### 3. Named Volume vs Container Writable Layer

A container's writable layer is ephemeral and destroyed when the container is removed. A named volume is managed independently by Docker outside the container root filesystem, allowing persistent data to outlive container recreation and upgrades.

### 4. `docker compose down` vs `docker compose down -v`

`docker compose down` stops and cleans up containers, networks, and internal links while preserving named volumes. Appending `-v` removes declared named volumes, irreversibly purging the database data.

### 5. Production Readiness Recommendations

Before taking this stack to production:

* Replace the development Flask server with an ASGI/WSGI production server (e.g., Gunicorn/Uvicorn).
* Inject credentials using dedicated secret stores (HashiCorp Vault, AWS Secrets Manager, or Docker Swarm Secrets) instead of plain text files.
* Enable Redis persistence (AOF/RDB) with a dedicated volume mount.
* Impose explicit memory and CPU limits (`deploy.resources.limits`) to avoid resource exhaustion.
EOF

```

```
