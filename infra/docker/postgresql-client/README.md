# PostgreSQL Client based on alpine:3.11
This docker file is used in Kubernetes to either run `psql` manually in a shell by launching the container as follows: 
```bash
kubectl run --rm -i -t postgres --image=c0dyhi11/postgresql-client:latest --restart=Never
```
Or to load a database schema via Kubernetes `ConfigMap` and `Job` by applying the following files:
```yaml
---
kind: ConfigMap
metadata:
  name: sql-schema
apiVersion: v1
data:
  schema.sql: |+
    CREATE DATABASE my_db;
    CREATE USER my_db WITH PASSWORD 'my_db';
    GRANT ALL PRIVILEGES ON DATABASE my_db to my_db;
    \c my_db
    CREATE TABLE my_table (
        uuid VARCHAR(255) PRIMARY KEY,
        row VARCHAR(255) NOT NULL,
    );

---
apiVersion: batch/v1
kind: Job
metadata:
  name: postgresql-schema
spec:
  template:
    spec:
      containers:
        - name: postgresql-schema
          image: c0dyhi11/postgresql-client:latest
          command: ["psql", "-h", "postgres", "-p", "5432", "-U", "postgres", "-f", "/opt/schema.sql"]
          volumeMounts:
          - name: sql-schema
            mountPath: /opt
          env:
          - name: PGPASSWORD
            value: "postgres"
      volumes:
        - name: sql-schema
          configMap:
            name: sql-schema
            items:
            - key: schema.sql
              path: schema.sql
      restartPolicy: Never

```