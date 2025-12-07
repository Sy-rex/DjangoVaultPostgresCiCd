#!/bin/bash

# Скрипт для получения секретов из Vault
# Использование: ./get-secrets.sh [path]
# Пример: ./get-secrets.sh secret/django-app/database

set -e

SECRET_PATH=${1:-"secret/django-app/database"}

echo "🔍 Получаем секреты из пути: $SECRET_PATH"

# Проверяем, что Vault pod готов
kubectl wait --for=condition=ready pod -l app.kubernetes.io/name=vault -n vault --timeout=60s

# Получаем секреты
kubectl exec -it vault-0 -n vault -- vault kv get "$SECRET_PATH"

