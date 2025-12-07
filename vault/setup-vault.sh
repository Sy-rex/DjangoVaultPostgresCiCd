#!/bin/bash

# Скрипт для установки Vault через Helm в Dev режиме
# Использование: ./setup-vault.sh

set -e

# Проверка наличия необходимых инструментов
command -v helm >/dev/null 2>&1 || { echo "❌ Ошибка: helm не установлен. Установите Helm 3.x." >&2; exit 1; }
command -v kubectl >/dev/null 2>&1 || { echo "❌ Ошибка: kubectl не установлен. Установите kubectl." >&2; exit 1; }

echo "🚀 Начинаем установку Vault..."

# Добавляем Helm репозиторий HashiCorp
echo "📦 Добавляем Helm репозиторий HashiCorp..."
helm repo add hashicorp https://helm.hashicorp.com

# Обновляем репозитории
echo "🔄 Обновляем Helm репозитории..."
helm repo update

# Создаем namespace vault, если его еще нет
echo "📁 Создаем namespace vault..."
kubectl create namespace vault --dry-run=client -o yaml | kubectl apply -f -

# Устанавливаем Vault в Dev режиме (без TLS, хранит данные в памяти)
echo "⚙️  Устанавливаем Vault в Dev режиме..."
helm install vault hashicorp/vault \
  --namespace vault \
  --set "server.dev.enabled=true" \
  --set "global.tlsDisable=true" \
  --wait

echo "✅ Vault успешно установлен!"
echo ""
echo "⏳ Ожидаем готовности Vault pod..."
kubectl wait --for=condition=ready pod -l app.kubernetes.io/name=vault -n vault --timeout=120s

echo ""
echo "🎉 Vault готов к использованию!"
echo ""
echo "Для настройки KV движка и секретов выполните:"
echo "  ./configure-vault.sh"
echo ""
echo "Или вручную:"
echo "  kubectl exec -it vault-0 -n vault -- /bin/sh"

