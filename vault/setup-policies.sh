#!/bin/bash

# Скрипт для настройки дополнительных политик Vault
# Использование: ./setup-policies.sh

set -e

echo "📋 Настраиваем политики доступа для Vault..."

# Проверяем, что Vault pod готов
kubectl wait --for=condition=ready pod -l app.kubernetes.io/name=vault -n vault --timeout=60s

# Создаем политику для Django приложения (если еще не создана)
echo "🔐 Создаем политику django-app..."
kubectl exec -it vault-0 -n vault -- vault policy write django-app - <<EOF
path "secret/data/django-app/*" {
  capabilities = ["read"]
}
EOF

# Создаем политику для чтения всех секретов (для админов)
echo "🔐 Создаем политику admin-read..."
kubectl exec -it vault-0 -n vault -- vault policy write admin-read - <<EOF
path "secret/data/*" {
  capabilities = ["read", "list"]
}
EOF

# Создаем политику для полного доступа (для админов)
echo "🔐 Создаем политику admin-full..."
kubectl exec -it vault-0 -n vault -- vault policy write admin-full - <<EOF
path "secret/data/*" {
  capabilities = ["create", "read", "update", "delete", "list"]
}
EOF

echo ""
echo "✅ Политики созданы!"
echo ""
echo "Доступные политики:"
kubectl exec -it vault-0 -n vault -- vault policy list

