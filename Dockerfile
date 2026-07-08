ARG ALPINE_VERSION
FROM alpine:${ALPINE_VERSION}
ARG TARGETARCH
# Major do Postgres client (pg_dump/pg_restore). Faz a tag da imagem bater com a
# versão real do client, em vez de depender do default do Alpine (que muda entre
# releases e fazia :16 e :17 virarem a mesma imagem).
ARG PG_MAJOR

ADD src/install.sh install.sh
RUN PG_MAJOR="${PG_MAJOR}" sh install.sh && rm install.sh

ENV POSTGRES_DATABASE ''
ENV POSTGRES_HOST ''
ENV POSTGRES_PORT 5432
ENV POSTGRES_USER ''
ENV POSTGRES_PASSWORD ''
ENV PGDUMP_EXTRA_OPTS ''
ENV S3_ACCESS_KEY_ID ''
ENV S3_SECRET_ACCESS_KEY ''
ENV S3_BUCKET ''
ENV S3_REGION 'us-west-1'
ENV S3_PATH 'backup'
ENV S3_ENDPOINT ''
ENV S3_S3V4 'no'
ENV SCHEDULE ''
ENV PASSPHRASE ''
ENV BACKUP_KEEP_DAYS ''
ENV API_PORT 80

ADD src/run.sh run.sh
ADD src/env.sh env.sh
ADD src/backup.sh backup.sh
ADD src/restore.sh restore.sh
ADD src/api.py api.py

CMD ["sh", "run.sh"]
