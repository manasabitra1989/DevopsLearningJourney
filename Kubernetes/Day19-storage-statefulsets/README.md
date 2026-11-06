# Day 19 – Kubernetes Storage & StatefulSets ☸️

**DevOps Winter Arc – 90 Days Challenge**

## 🎯 Objective

Understand how Kubernetes manages persistent storage for stateful applications and demonstrate that PostgreSQL database records survive Pod deletion and recreation.

### Topics Covered
- PersistentVolume (PV)
- PersistentVolumeClaim (PVC)
- StorageClass
- StatefulSet
- Headless Service
- PostgreSQL database deployment
- Data persistence and troubleshooting

---

## 1. Understanding Kubernetes Storage

| Component | Description |
|---|---|
| PersistentVolume (PV) | Storage resource available in the Kubernetes cluster |
| PersistentVolumeClaim (PVC) | Request for persistent storage |
| StorageClass | Defines how storage is provisioned |
| StatefulSet | Manages Pods with stable identities and persistent storage |
| Headless Service | Provides DNS-based discovery of individual Pods |

### Storage Architecture

```text
Kubernetes StatefulSet (pg)
          |
          v
     Pod (pg-0)
          |
          v
   PVC (data-pg-0)
          |
          v
   PersistentVolume
          |
          v
  Underlying Storage
```

**Key Learning:** Persistent storage allows application data to survive Pod replacement.

---

## 2. Inspecting Kubernetes Storage

Commands executed:

```bash
kubectl get storageclass
kubectl get pv
kubectl get pvc -A
kubectl describe storageclass standard
```

These commands help identify available storage classes, persistent volumes, and existing volume claims.

**Observation:** The StorageClass must match the storage configuration requested by the application.

---

## 3. Creating Namespace and Secret

Created a dedicated namespace:

```bash
kubectl create namespace day19-storage
```

Created a Kubernetes Secret to store a dummy PostgreSQL password:

```bash
kubectl create secret generic pg-secret \
  --from-literal='POSTGRES_PASSWORD=<LAB_PASSWORD>' \
  -n day19-storage
```

`<LAB_PASSWORD>` is a placeholder. The actual lab password is not included in this repository.

**Learning:** Kubernetes Secrets separate sensitive configuration from application manifests.

---

## 4. Creating the Headless Service

File: `pg-headless.yaml`

```yaml
apiVersion: v1
kind: Service
metadata:
  name: pg-headless
  namespace: day19-storage
spec:
  clusterIP: None
  selector:
    app: pg
  ports:
    - name: postgres
      port: 5432
      targetPort: 5432
```

Deployment:

```bash
kubectl apply -f pg-headless.yaml
kubectl get svc -n day19-storage
```

**Learning:** A Headless Service supports stable DNS identities for StatefulSet Pods.

---

## 5. Deploying PostgreSQL StatefulSet

File: `postgres-statefulset.yaml`

The StatefulSet configuration includes:

- PostgreSQL 16 Alpine container image
- One replica
- PostgreSQL database `winterarc`
- Database user `appuser`
- Password retrieved from Kubernetes Secret
- Persistent storage mounted at `/var/lib/postgresql/data`
- `volumeClaimTemplates` requesting 1Gi storage
- `ReadWriteOnce` access mode

Deployment commands:

```bash
kubectl apply -f postgres-statefulset.yaml

kubectl get statefulset,pods,pvc -n day19-storage -w
```

Expected resources:

```text
StatefulSet: pg
Pod:         pg-0
PVC:         data-pg-0
```

**Learning:** StatefulSets provide stable Pod identities and can create dedicated persistent storage claims.

---

## 6. PostgreSQL Database Persistence Test

### Step 1 – Connect to PostgreSQL

```bash
kubectl exec -it -n day19-storage pg-0 -- \
  psql -U appuser -d winterarc
```

### Step 2 – Create Table and Insert Record

```sql
CREATE TABLE lab_notes (
    id INT PRIMARY KEY,
    note TEXT
);

INSERT INTO lab_notes
VALUES (1, 'data-survives-pod-delete');

SELECT * FROM lab_notes;
```

Expected result:

```text
 id |           note
----+--------------------------
  1 | data-survives-pod-delete
(1 row)
```

Exit PostgreSQL:

```sql
\q
```

### Step 3 – Delete PostgreSQL Pod

```bash
kubectl get pvc -n day19-storage

kubectl delete pod pg-0 -n day19-storage

kubectl get pods -n day19-storage -w
```

The StatefulSet controller should recreate the deleted Pod with the same name, `pg-0`.

### Step 4 – Verify Data Persistence

After the replacement Pod becomes Ready:

```bash
kubectl exec -n day19-storage pg-0 -- \
  psql -U appuser -d winterarc \
  -c "SELECT * FROM lab_notes;"
```

**Expected Result:** The original database record remains available after Pod recreation.

**Key Learning:** The replacement Pod reuses the persistent claim and storage volume, preserving the database files.

---

## 7. Inspecting the Storage Chain

Commands:

```bash
kubectl get statefulset,pods,pvc,pv -n day19-storage

kubectl describe pvc data-pg-0 -n day19-storage

kubectl get events -n day19-storage \
  --sort-by=.lastTimestamp
```

Storage relationship:

```text
StatefulSet
    |
    v
Pod (pg-0)
    |
    v
PVC (data-pg-0)
    |
    v
PV
    |
    v
Storage Provisioner / Node Storage
```

**Learning:** The PVC connects the application to the underlying storage through a bound PersistentVolume.

---

## 8. Troubleshooting

| Issue | Possible Cause | Troubleshooting |
|---|---|---|
| PVC Pending | Incorrect StorageClass | Check available StorageClasses |
| PVC Pending | Storage provisioner failure | Inspect PVC Events |
| Pod Pending | PVC not Bound | Describe Pod and PVC |
| PostgreSQL restarting | Database configuration or Secret issue | Check container logs |
| Data missing | Incorrect PVC or database | Verify volume and SQL query |

Useful commands:

```bash
kubectl describe pvc data-pg-0 -n day19-storage

kubectl describe pod pg-0 -n day19-storage

kubectl logs pg-0 -n day19-storage

kubectl get events -n day19-storage \
  --sort-by=.lastTimestamp
```

---

## 9. Interview Questions & Answers

**Q1. What is the difference between PV and PVC?**

PV represents available storage, while PVC requests storage from Kubernetes.

**Q2. Why shouldn't database files be stored in a container's writable filesystem?**

Container writable storage is tied to the container lifecycle and may be lost during replacement.

**Q3. What does StorageClass do?**

It defines storage provisioning characteristics and can enable dynamic volume provisioning.

**Q4. What is `volumeClaimTemplates`?**

It creates a dedicated PersistentVolumeClaim for each StatefulSet Pod.

**Q5. Why does PostgreSQL data survive Pod deletion?**

The replacement Pod can reconnect to the existing PVC and persistent volume.

**Q6. Deployment vs StatefulSet?**

Deployments manage interchangeable Pods. StatefulSets provide stable Pod identities and ordered management.

**Q7. What is ReadWriteOnce?**

The volume can be mounted read-write by one node at a time.

**Q8. Why use a Headless Service?**

It enables DNS-based discovery of individual StatefulSet Pods.

**Q9. Why can a PVC remain Pending?**

Possible causes include missing StorageClass, provisioner failures, or unsatisfied storage requirements.

**Q10. Does deleting a StatefulSet Pod delete its PVC?**

Normally, deleting only the Pod does not delete its PVC.

**Q11. What happens when a PVC is deleted?**

Depending on the reclaim policy, underlying storage may be retained or deleted.

**Q12. Is persistent storage equivalent to database backup?**

No. Persistent storage protects against certain Pod lifecycle failures but does not replace backups or disaster recovery.

---

## 10. Screenshots / Evidence

Add screenshots after completing the lab.

| Evidence | Screenshot |
|---|---|
| StorageClass inspection | `screenshots/01-storageclass.png` |
| PVC showing Bound | `screenshots/02-pvc-bound.png` |
| Database record before deletion | `screenshots/03-before-deletion.png` |
| Pod recreation | `screenshots/04-pod-recreation.png` |
| Record after Pod recreation | `screenshots/05-after-deletion.png` |

---

## 11. Cleanup

After completing the lab and saving evidence:

```bash
kubectl delete namespace day19-storage
kubectl get pv
```

**Note:** Deleting the namespace removes the lab resources. Underlying storage may also be deleted depending on the PV reclaim policy.

---

## 12. Key Takeaways

- PV provides storage resources to Kubernetes.
- PVC requests and binds to persistent storage.
- StorageClass defines storage provisioning.
- StatefulSets maintain stable Pod identities.
- Headless Services support individual Pod DNS identities.
- `volumeClaimTemplates` creates persistent claims for StatefulSet Pods.
- PostgreSQL data can survive Pod deletion when the persistent volume is reused.
- Persistent storage is not a replacement for backups.

