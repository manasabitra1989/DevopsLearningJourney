Here is the complete, submission-ready `README.md` file content based on your completed lab evidence, commands, and assignment rubric:

```markdown
# Day 11: Docker Storage & Networking Lab

## 1. Problem Statement & Architecture Summary
Containers are ephemeral by default[cite: 14, 18]. When a container is removed, all writes to its writable layer are permanently lost[cite: 18]. Stateful services such as relational databases require persistent storage decoupled from the compute lifecycle, reliable network discovery between dependent services, and tested disaster recovery backup procedures[cite: 14, 18].

This project deploys a PostgreSQL 16 Alpine container attached to a persistent Docker named volume (`pgdata`) on an isolated user-defined bridge network (`app-net`)[cite: 14, 15]. The lab verifies data survival across container destruction, evaluates Docker embedded DNS resolution, troubleshoots host-port namespace collisions, and executes an end-to-end file-level cold backup and recovery into an independent volume (`pgdata2`)[cite: 14, 16, 27].

---

## 2. Environment & Configuration Details
- **OS Environment**: Linux / WSL (Ubuntu)[cite: 19]
- **Runtime**: Docker Engine & Docker Desktop[cite: 15]
- **Network**: `app-net` (Driver: `bridge`, Scope: `local`)[cite: 19]
- **Storage Volumes**: `pgdata` (Primary database volume), `pgdata2` (Restore target volume)[cite: 19, 27]
- **Database Engine**: PostgreSQL 16 Alpine (`postgres:16-alpine`)[cite: 20]
- **Ports Tested**: Host ports `18080` (collision) and `18081` (remediated) mapped to container port `80`[cite: 16, 25]

---

## 3. Step-by-Step Implementation & Evidence

### Step 1: Network & Volume Provisioning
Created the user-defined bridge network and the dedicated named volume[cite: 15]:
```bash
docker network create app-net
docker volume create pgdata
docker network ls
docker volume ls

```

[cite: 16, 19]

---

### Step 2: Database Deployment & Readiness Check

Launched PostgreSQL mounted to `pgdata` on `app-net` and verified socket readiness:

```bash
docker run -d --name db --network app-net \
  -e POSTGRES_USER=postgres \
  -e POSTGRES_PASSWORD=changeme \
  -e POSTGRES_DB=shop \
  -v pgdata:/var/lib/postgresql/data \
  postgres:16-alpine

docker ps
docker exec db pg_isready -U postgres -d shop

```

*Output*: `/var/run/postgresql:5432 - accepting connections`.

[cite: 16, 20]

---

### Step 3: Data Seeding Prior to Deletion

Created table `notes` and inserted a test record:

```bash
docker exec -it db psql -U postgres -d shop -c "CREATE TABLE IF NOT EXISTS notes (id SERIAL PRIMARY KEY, message TEXT);"
docker exec -it db psql -U postgres -d shop -c "INSERT INTO notes (message) VALUES ('I survive\!');"
docker exec db psql -U postgres -d shop -c "SELECT * FROM notes;"

```

[cite: 16, 21]

---

### Step 4: Proving Data Persistence Across Container Destruction

Force-removed the running container `db` (`docker rm -f db`), removing its ephemeral writable layer[cite: 15, 18, 22]. Spun up a new container instance referencing the identical named volume `pgdata`[cite: 15, 22]:

```bash
docker rm -f db

docker run -d --name db --network app-net \
  -e POSTGRES_USER=postgres \
  -e POSTGRES_PASSWORD=changeme \
  -e POSTGRES_DB=shop \
  -v pgdata:/var/lib/postgresql/data \
  postgres:16-alpine

docker exec db pg_isready -U postgres -d shop
docker exec -it db psql -U postgres -d shop -c "SELECT * from notes"

```

*Result*: Row `1 | I survive\!` persisted in the new container[cite: 22].

[cite: 16, 22]

---

### Step 5: Container Networking via Internal DNS

Connected to the database from a secondary, ephemeral container using the internal hostname `db`:

```bash
docker run --rm --network app-net -e PGPASSWORD=changeme postgres:16-alpine \
  psql -h db -U postgres -d shop -c "SELECT * FROM notes;"

```

[cite: 16, 23]

---

### Step 6: DNS Resolution Comparison

Compared DNS resolution behavior between default bridge and custom bridge networks:

```bash
# Default bridge lookup (Fails)
docker run --rm alpine ping -c 1 db

# Custom user-defined bridge lookup (Succeeds via 127.0.0.11 embedded DNS)
docker run --rm --network app-net alpine ping -c 1 db

```

*Result*: Default bridge returned `ping: bad address 'db'`; custom bridge resolved `db` to `172.18.0.2`[cite: 24].

[cite: 16, 24]

---

### Step 7 & 8: Host Port Collision Diagnosis & Remediation

Deliberately attempted to bind two separate web containers (`w1` and `w2`) to host port `18080`[cite: 16]:

```bash
# w1 binds host port 18080 successfully
docker run -d --name w1 -p 18080:80 nginx:alpine

# w2 attempts to reuse host port 18080 (Causes allocation conflict)
docker run -d --name w2 -p 18080:80 nginx:alpine

```

*Error observed*: `driver failed programming external connectivity... Bind for 0.0.0.0:18080 failed: port is already allocated`[cite: 25].

*Remediation*: Removed the failed container and mapped host port `18081`:

```bash
docker rm -f w2
docker run -d --name w2 -p 18081:80 nginx:alpine

```



---

### Step 9: Volume Backup Verification

Safely stopped the database engine to guarantee write consistency, mounted the volume to a helper container, and created a compressed file archive[cite: 16, 18, 26]:

```bash
docker stop db
docker run --rm -v pgdata:/data -v "$(pwd)":/backup alpine tar czf /backup/pgdata-backup.tgz -C /data .
ls -lh pgdata-backup.tgz
docker start db
docker exec db pg_isready -U postgres

```

*Archive created*: `pgdata-backup.tgz` (`6.5M`)[cite: 26].

[cite: 16, 26]

---

### Step 10: Disaster Recovery Restoration Test (Extension)

Verified backup integrity by restoring `pgdata-backup.tgz` into an independent volume (`pgdata2`)[cite: 27]:

```bash
docker volume create pgdata2
docker run --rm -v pgdata2:/data -v "$(pwd)":/backup:ro alpine tar xzf /backup/pgdata-backup.tgz -C /data
docker run -d --name db-restore-test --network app-net -e POSTGRES_PASSWORD=changeme -v pgdata2:/var/lib/postgresql/data postgres:16-alpine
docker logs db-restore-test
docker exec db-restore-test psql -U postgres -d shop -c "SELECT * FROM notes;"

```

*Result*: PostgreSQL logs reported `PostgreSQL Database directory appears to contain a database; Skipping initialization` and query confirmed data recovery[cite: 27].

[cite: 27]

---

## 4. Incident & Troubleshooting Summary

| Symptom / Error | Root Cause Analysis | Remediation Taken |
| --- | --- | --- |
| `-bash: !': event not found`[cite: 21] | Bash evaluates `!` in double quotes as history expansion prior to command dispatch[cite: 21]. | Escaped the character: `VALUES ('I survive\!');`[cite: 21] |
| `create %cd%: "%cd%" includes invalid characters...` | Command Prompt syntax (`%cd%`) was used inside a Linux/WSL terminal, causing Docker to interpret `%cd%` as a volume name[cite: 16]. | Replaced with POSIX path substitution: `"$(pwd)"`[cite: 26]. |
| `Bind for 0.0.0.0:18080 failed: port is already allocated`[cite: 25] | Two distinct containers attempted to publish to the same host TCP socket.

 | Cleared failed container `w2` and published over host port `18081`.

 |

---

## 5. Interview Readiness Q&A

### 1. What is a Docker volume, and why use one?

A Docker volume is storage managed on the host filesystem outside the lifecycle of containers. Unlike ephemeral writable layers (Overlay2) that are deleted when a container is removed, volumes persist independently and offer native I/O performance.

### 2. What proved that your PostgreSQL data persisted?

A row was inserted into container `db`[cite: 15, 21]. The container was forcefully deleted via `docker rm -f db`[cite: 15, 22]. A replacement container was launched with `-v pgdata:/var/lib/postgresql/data`, and running `SELECT * FROM notes;` returned the exact initial record[cite: 15, 22].

### 3. Why use a user-defined bridge network?

User-defined bridge networks provide automatic service discovery via Docker's embedded DNS server (`127.0.0.11`), allowing containers to resolve each other by container name or alias[cite: 15, 18, 24]. The default bridge network does not provide automatic name resolution.

### 4. Why did the host-port conflict happen?

Host network ports exist in a single root namespace[cite: 25]. While multiple containers can expose the same private container port (e.g., port 80), Docker cannot bind more than one container socket to the same host IP and port tuple.

### 5. What is the difference between a volume and a backup?

A volume is live, mounted working storage intended for runtime persistence. A backup is an external, point-in-time point of recovery (such as a compressed tarball or SQL dump) designed to restore services in disaster recovery events.

### 6. Why stop PostgreSQL for this archive exercise?

Stopping PostgreSQL ensures that active memory pages and uncommitted Write-Ahead Logs (WAL) are flushed cleanly to disk[cite: 16, 18]. Archiving raw filesystem blocks of an actively writing database engine produces torn pages and catalog corruption[cite: 16, 18].

---

## 6. Repository Structure

```text
day11-storage-networking/
├── README.md
├── pgdata-backup.tgz
└── evidence/
    ├── 01-network-volume.png
    ├── 02-postgres-running.png
    ├── 03-data-before-recreation.png
    ├── 04-data-persistence.png
    ├── 05-container-networking.png
    ├── 06-dns-test.png
    ├── 07-port-conflict-and-fix.png
    ├── 08-volume-backup.png
    └── 09-Restore-data-pgdata2.png

```

```

```
