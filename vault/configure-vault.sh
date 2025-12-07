#!/bin/bash

# Скрипт для настройки Vault: включение KV движка и запись секретов
# Использование: ./configure-vault.sh

set -e

# Проверка наличия kubectl
command -v kubectl >/dev/null 2>&1 || { echo "❌ Ошибка: kubectl не установлен. Установите kubectl." >&2; exit 1; }

echo "🔧 Начинаем настройку Vault..."

# Проверяем, что Vault pod готов
echo "⏳ Проверяем готовность Vault..."
kubectl wait --for=condition=ready pod -l app.kubernetes.io/name=vault -n vault --timeout=60s

echo "📝 Настраиваем KV движок версии 2..."

# Включаем KV движок версии 2
kubectl exec -it vault-0 -n vault -- vault secrets enable -path=secret kv-v2

echo "💾 Записываем секреты для Django приложения..."

# Записываем секреты для Django приложения
kubectl exec -it vault-0 -n vault -- vault kv put secret/django-app/database \
  db_name="django_prod" \
  db_user="django_user" \
  db_password="SuperSecret123!" \
  secret_key="very-secret-key-prod"

echo "✅ Секреты успешно записаны!"

echo ""
echo "🔍 Проверяем записанные секреты..."
kubectl exec -it vault-0 -n vault -- vault kv get secret/django-app/database

echo ""
echo "📋 Настраиваем политику доступа..."

# Создаем политику для Django приложения
kubectl exec -it vault-0 -n vault -- vault policy write django-app - <<EOF
path "secret/data/django-app/*" {
  capabilities = ["read"]
}
EOF

echo "✅ Политика django-app создана!"

echo ""
echo "🔐 Проверяем политику..."
kubectl exec -it vault-0 -n vault -- vault policy read django-app

echo ""
echo "🎉 Настройка Vault завершена!"
echo ""
echo "Секреты доступны по пути: secret/django-app/database"
echo "Политика доступа: django-app"

