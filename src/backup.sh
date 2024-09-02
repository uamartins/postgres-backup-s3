#! /bin/sh

set -eu
set -o pipefail

source ./env.sh

echo "Creating backup of $POSTGRES_DATABASE database..."
pg_dump --format=custom \
        -h $POSTGRES_HOST \
        -p $POSTGRES_PORT \
        -U $POSTGRES_USER \
        -d $POSTGRES_DATABASE \
        $PGDUMP_EXTRA_OPTS \
        > db.dump

echo "Compressing the backup file..."
gzip db.dump
local_file="db.dump.gz"

timestamp=$(date +"%Y-%m-%dT%H:%M:%S")
s3_uri_base="s3://${S3_BUCKET}/${S3_PREFIX}/${POSTGRES_DATABASE}_${timestamp}.dump.gz"

if [ -n "$PASSPHRASE" ]; then
  echo "Encrypting backup..."
  rm -f db.dump.gz.gpg
  gpg --symmetric --batch --passphrase "$PASSPHRASE" "$local_file"
  rm "$local_file"
  local_file="db.dump.gz.gpg"
  s3_uri="${s3_uri_base}.gpg"
else
  s3_uri="$s3_uri_base"
fi

echo "Uploading backup to $S3_BUCKET..."
aws $aws_args s3 cp "$local_file" "$s3_uri"
rm "$local_file"

echo "Backup complete."

if [ -n "$BACKUP_KEEP_DAYS" ]; then
  sec=$((86400 * BACKUP_KEEP_DAYS))
  date_from_remove=$(date -u -d "@$(($(date +%s) - sec))" +%Y-%m-%dT%H:%M:%SZ)

  echo "Removing old backups from $S3_BUCKET..."
  aws $aws_args s3api list-objects \
    --bucket "${S3_BUCKET}" \
    --prefix "${S3_PREFIX}" \
    --query "Contents[?LastModified<='${date_from_remove}'].Key" \
    --output text \
    | tr '\t' '\n' \
    | while IFS= read -r key; do
        if [ -n "$key" ]; then
          aws $aws_args s3 rm "s3://${S3_BUCKET}/${key}"
        fi
      done
  echo "Removal complete."
fi