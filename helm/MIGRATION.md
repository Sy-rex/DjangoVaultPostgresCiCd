# Инструкция по миграции на Helm

## Быстрая миграция

### 1. Решение проблемы с существующими namespace

Если namespace уже существуют, у вас есть два варианта:

#### Вариант A: Обновить существующие namespace (рекомендуется)

Добавьте метки и аннотации Helm к существующим namespace:

**Windows (PowerShell):**
```powershell
.\helm\fix-namespace.ps1
```

**Linux/Mac:**
```bash
chmod +x helm/fix-namespace.sh
./helm/fix-namespace.sh
```

**Или вручную:**
```bash
kubectl label namespace django-app app.kubernetes.io/managed-by=Helm --overwrite
kubectl label namespace django-app app.kubernetes.io/name=django-app --overwrite
kubectl label namespace django-app app.kubernetes.io/instance=django-app --overwrite
kubectl annotate namespace django-app meta.helm.sh/release-name=django-app --overwrite
kubectl annotate namespace django-app meta.helm.sh/release-namespace=default --overwrite

kubectl label namespace vault app.kubernetes.io/managed-by=Helm --overwrite
kubectl label namespace vault app.kubernetes.io/name=django-app --overwrite
kubectl label namespace vault app.kubernetes.io/instance=django-app --overwrite
kubectl annotate namespace vault meta.helm.sh/release-name=django-app --overwrite
kubectl annotate namespace vault meta.helm.sh/release-namespace=default --overwrite
```

#### Вариант B: Удалить и пересоздать (если нет важных данных)

```bash
kubectl delete namespace django-app vault
```

**ВНИМАНИЕ**: Это удалит все ресурсы в этих namespace! Убедитесь, что у вас есть резервные копии данных.

### 2. Установка через Helm

```bash
# Базовая установка с дефолтными значениями
helm install django-app ./helm/django-app

# Или с кастомными значениями
helm install django-app ./helm/django-app -f helm/django-app/values-production.yaml
```

### 3. Проверка установки

```bash
# Проверить статус релиза
helm status django-app

# Посмотреть все ресурсы
helm get manifest django-app

# Проверить логи
kubectl logs -n django-app -l app=django-app
```

## Настройка приватного Docker Registry

### Для локального registry (localhost:5000)

В `values.yaml` уже настроено:
```yaml
global:
  imageRegistry: "localhost:5000"
  imagePullSecrets: []
```

### Для удаленного приватного registry

1. Создайте imagePullSecret:
```bash
kubectl create secret docker-registry regcred \
  --docker-server=your-registry.com:5000 \
  --docker-username=<username> \
  --docker-password=<password> \
  --docker-email=<email> \
  --namespace=django-app

kubectl create secret docker-registry regcred \
  --docker-server=your-registry.com:5000 \
  --docker-username=<username> \
  --docker-password=<password> \
  --docker-email=<email> \
  --namespace=vault
```

2. Обновите `values.yaml`:
```yaml
global:
  imageRegistry: "your-registry.com:5000"
  imagePullSecrets: ["regcred"]
```

3. Установите/обновите:
```bash
helm upgrade --install django-app ./helm/django-app
```

## Обновление приложения

```bash
# Обновить с новыми значениями
helm upgrade django-app ./helm/django-app

# Обновить с новым файлом values
helm upgrade django-app ./helm/django-app -f my-values.yaml

# Обновить образ Django (например, новый тег)
helm upgrade django-app ./helm/django-app --set django.image.tag=v3
```

## Откат изменений

```bash
# Посмотреть историю релизов
helm history django-app

# Откатиться к предыдущей версии
helm rollback django-app
```

## Удаление

```bash
helm uninstall django-app
```

## Основные преимущества Helm

1. **Управление версиями**: Легко откатывать изменения
2. **Параметризация**: Все настройки в одном месте (values.yaml)
3. **Шаблонизация**: Переиспользование конфигураций
4. **Зависимости**: Можно добавить зависимости от других charts
5. **Упрощенное обновление**: Одна команда для обновления всего приложения

