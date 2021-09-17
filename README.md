# MongoDB -> S3 (minio) docker/kubernetes backup
Docker image to backup MongoDB 4.x to S3 (minio) using mongodump and compress gzip.

![](images/cover.png)

## Features
- [x] Supports custom S3 endpoints (e.g. minio)
- [x] Uses piping instead of tmp file
- [x] Compression is done with gzip
- [x] Creates bucket if it's not created
- [x] Can be run in Kubernetes or Docker

## Configuration
```bash
S3_BUCKET=mongo1-backups
S3_URI=http://s3-key:s3-secret@s3.host.tld
MONGODB_URI=mongodb://mongo-host:27017/db-name
MONGODB_READ_PREFERENCE=secondaryPreferred #default - `secondaryPreferred`
MONGODB_OPLOG=true #default - `false`
RETENTION_PERIOD=7d #default - `14d`
```

## Cron backup with kubernetes

How usage with [Helm-CronJob](https://github.com/bambash/helm-cronjobs) chart.

values.yaml:
```
---
jobs:
  - name: mongodb-backup
    image:
      repository: registry.example.org/kube-public/mongodump_minio
      tag: 1.0.0
      imagePullPolicy: IfNotPresent
    securityContext:
      runAsUser: 1000
      runAsGroup: 1000    
    schedule: "0 1 * * *"
    failedJobsHistoryLimit: 1
    successfulJobsHistoryLimit: 3
    concurrencyPolicy: Forbid
    restartPolicy: OnFailure
    serviceAccount: {}
    env:
    - name: MONGODB_URI
      value: "mongodb://user:pass@mongodb-example-headless:27017"
    - name: MONGODB_OPLOG
      value: "true"
    - name: S3_URI
      value: "http://user:pass@minio.example.org"
    - name: S3_BUCKET
      value: backup-mongodb
    - name: RETENTION_PERIOD
      value: 7d
```
Deploy cronjob:

```
helm upgrade --install  backup-mongodb -n backup-mongodb -f values.yaml . --set "jobs[0].env[0].value=$MONGODB_URI_SECRET" --set "jobs[0].env[2].value=$S3_URI_SECRET"
```