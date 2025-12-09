FROM alpine:3.18

RUN apk add --no-cache unzip

# Установка Vault
ARG VAULT_VERSION="1.19.3"
RUN wget https://hashicorp-releases.yandexcloud.net/vault/${VAULT_VERSION}/vault_${VAULT_VERSION}_linux_amd64.zip && \
    unzip vault_${VAULT_VERSION}_linux_amd64.zip && \
    mv vault /usr/local/bin/ && \
    rm vault_${VAULT_VERSION}_linux_amd64.zip

RUN mkdir -p /vault/config /vault/data

RUN addgroup -S vault && \
    adduser -S -D -H -u 1000 -s /sbin/nologin -G vault vault -h /home/vault

RUN mkdir -p /home/vault && \
    chown -R vault:vault /vault /home/vault

COPY vault-config.hcl /vault/config/

USER vault

EXPOSE 8200
CMD ["vault", "server", "-config=/vault/config/vault-config.hcl"]