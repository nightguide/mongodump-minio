FROM bitnami/minideb:buster

ARG MONGODB_TOOLS_VER=100.5.0

WORKDIR /scripts

RUN set -eux; \
    apt-get update && apt-get install --no-install-recommends -y \
        wget=1.20.*; \
    wget --no-check-certificate https://dl.minio.io/client/mc/release/linux-amd64/mc -O /sbin/mc && chmod +x /sbin/mc; \
    wget --no-check-certificate https://fastdl.mongodb.org/tools/db/mongodb-database-tools-debian10-x86_64-${MONGODB_TOOLS_VER}.deb -P /tmp; \
    apt-get install --no-install-recommends -y /tmp/mongodb-database-tools-debian10-x86_64-${MONGODB_TOOLS_VER}.deb; \
    rm -rf  /var/lib/apt/lists/* \
			/tmp/*



COPY scripts/backup-mongodb.sh .
RUN  chmod -R go+rwx /scripts;


ENV MONGODB_URI ""
ENV MONGODB_OPLOG ""
ENV MONGODB_READ_PREFERENCE "secondaryPreferred"
ENV S3_URI ""
ENV S3_BUCKET ""
ENV RETENTION_PERIOD "14d"

CMD ["/scripts/backup-mongodb.sh"]