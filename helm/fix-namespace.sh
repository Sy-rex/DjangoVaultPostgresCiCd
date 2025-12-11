#!/bin/bash
# Скрипт для добавления меток Helm к существующим namespace
# Запустите этот скрипт перед установкой Helm chart, если namespace уже существуют

RELEASE_NAME="django-app"
RELEASE_NAMESPACE="default"

# Обновление namespace django-app
kubectl label namespace django-app app.kubernetes.io/managed-by=Helm --overwrite
kubectl label namespace django-app app.kubernetes.io/name=django-app --overwrite
kubectl label namespace django-app app.kubernetes.io/instance=$RELEASE_NAME --overwrite
kubectl annotate namespace django-app meta.helm.sh/release-name=$RELEASE_NAME --overwrite
kubectl annotate namespace django-app meta.helm.sh/release-namespace=$RELEASE_NAMESPACE --overwrite

# Обновление namespace vault
kubectl label namespace vault app.kubernetes.io/managed-by=Helm --overwrite
kubectl label namespace vault app.kubernetes.io/name=django-app --overwrite
kubectl label namespace vault app.kubernetes.io/instance=$RELEASE_NAME --overwrite
kubectl annotate namespace vault meta.helm.sh/release-name=$RELEASE_NAME --overwrite
kubectl annotate namespace vault meta.helm.sh/release-namespace=$RELEASE_NAMESPACE --overwrite

echo "Namespace метки и аннотации обновлены. Теперь можно установить Helm chart."

