#! /bin/sh

set -eux
set -o pipefail

apk update

# install pg_dump/pg_restore do major pedido (PG_MAJOR). Versionado de propósito:
# o client precisa ser >= a versão do servidor, e a tag da imagem deve refletir a
# versão real. PG_MAJOR vazio cai no pacote default do Alpine (compat retroativa).
apk add "postgresql${PG_MAJOR}-client"

# install gpg
apk add gnupg

# install python and flask for api
apk add python3 py3-flask

apk add aws-cli

# install go-cron
apk add curl
curl -L https://github.com/ivoronin/go-cron/releases/download/v0.0.5/go-cron_0.0.5_linux_${TARGETARCH}.tar.gz -O
tar xvf go-cron_0.0.5_linux_${TARGETARCH}.tar.gz
rm go-cron_0.0.5_linux_${TARGETARCH}.tar.gz
mv go-cron /usr/local/bin/go-cron
chmod u+x /usr/local/bin/go-cron
apk del curl


# cleanup
rm -rf /var/cache/apk/*
