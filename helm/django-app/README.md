# Django App Helm Chart

Helm chart для развертывания Django приложения с PostgreSQL и Vault.

## Установка

### Базовая установка

```bash
helm install django-app ./helm/django-app
```

### Установка с кастомными значениями

```bash
helm install django-app ./helm/django-app -f my-values.yaml
```

### Обновление

```bash
helm upgrade django-app ./helm/django-app
```

### Удаление

```bash
helm uninstall django-app
```

## Настройка приватного Docker Registry

### 1. Настройка values.yaml

Отредактируйте `values.yaml`:

```yaml
global:
  imageRegistry: "your-registry.com:5000"  # Ваш приватный registry
  imagePullSecrets: ["regcred"]  # Имя secret для аутентификации
```

### 2. Создание imagePullSecret (если требуется)

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

### 3. Использование локального registry (localhost:5000)

Для локального registry без аутентификации:

```yaml
global:
  imageRegistry: "localhost:5000"
  imagePullSecrets: []  # Пустой массив
```

И установите `imagePullPolicy: IfNotPresent` или `Never` для локальных образов.

## Конфигурация образов

Все образы настраиваются через `values.yaml`:

- **Django**: `django.image.repository` и `django.image.tag`
- **PostgreSQL**: `postgres.image.repository` и `postgres.image.tag`
- **Vault**: `vault.image.repository` и `vault.image.tag` (кастомный образ)

## Значения по умолчанию

См. `values.yaml` для полного списка настраиваемых параметров.

## Примечания

- Vault использует кастомный образ `vault-custom:latest` (настроено для работы в странах с ограничениями)
- Secrets хранятся в values.yaml (для production используйте внешнее управление секретами)
- PostgreSQL использует PersistentVolumeClaim для хранения данных

