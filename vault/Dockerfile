# Используем базовый образ Alpine для минимального размера
FROM alpine:3.18

# Установка необходимых пакетов
RUN apk add --no-cache unzip

# Установка Vault
ARG VAULT_VERSION="1.19.3"
RUN wget https://hashicorp-releases.yandexcloud.net/vault/${VAULT_VERSION}/vault_${VAULT_VERSION}_linux_amd64.zip && \
    unzip vault_${VAULT_VERSION}_linux_amd64.zip && \
    mv vault /usr/local/bin/ && \
    rm vault_${VAULT_VERSION}_linux_amd64.zip

# Создание директорий
RUN mkdir -p /vault/config /vault/data && \
    adduser -S -D -H -u 1000 vault && \
    chown -R vault:vault /vault

# Копируем конфигурацию
COPY vault-config.hcl /vault/config/

# Переключаемся на пользователя vault
USER vault

# Запуск Vault
EXPOSE 8200
CMD ["vault", "server", "-config=/vault/config/vault-config.hcl"]
