# Проверка работоспособности приложения

## Статус всех компонентов

Проверьте, что все поды работают:

```powershell
kubectl get pods -n django-app
kubectl get pods -n vault
```

Все поды должны быть в статусе `Running` и `READY 1/1`.

## Проверка сервисов

```powershell
kubectl get svc -n django-app
kubectl get ingress -n django-app
```

## Доступ к приложению

### Вариант 1: Через minikube service

```powershell
minikube service django-service -n django-app
```

Это откроет браузер с приложением.

### Вариант 2: Через NodePort напрямую

```powershell
minikube ip
# Используйте полученный IP и порт из kubectl get svc (например, 32194)
# http://<minikube-ip>:32194
```

### Вариант 3: Через Ingress

1. Добавьте в `C:\Windows\System32\drivers\etc\hosts`:
```
192.168.49.2  django.local
```

2. Откройте в браузере: `http://django.local`

## Проверка базы данных

```powershell
# Проверить логи PostgreSQL
kubectl logs -n django-app deployment/postgres-deployment --tail=50

# Подключиться к базе (опционально)
kubectl exec -it deployment/postgres-deployment -n django-app -- psql -U postgres -d django_prod
```

## Проверка Vault

```powershell
# Проверить статус Vault
kubectl logs -n vault deployment/vault --tail=50

# Получить URL Vault
kubectl get svc -n vault
```

## Выполнение миграций (если нужно)

Если база данных была пересоздана, выполните миграции:

```powershell
kubectl exec -it deployment/django-deployment -n django-app -- python manage.py migrate
```

## Создание суперпользователя Django (опционально)

```powershell
kubectl exec -it deployment/django-deployment -n django-app -- python manage.py createsuperuser
```

## Проверка логов приложения

```powershell
# Логи всех подов Django
kubectl logs -n django-app -l app=django-app --tail=100

# Логи конкретного пода
kubectl logs -n django-app <pod-name> --tail=100
```

## Проверка health endpoint

```powershell
# Через curl (если установлен)
curl http://django.local/health/

# Или через PowerShell
Invoke-WebRequest -Uri http://django.local/health/
```

## Устранение проблем

### Если поды не запускаются

```powershell
# Проверить описание пода
kubectl describe pod <pod-name> -n django-app

# Проверить события
kubectl get events -n django-app --sort-by='.lastTimestamp'
```

### Если ошибка 500

1. Проверьте логи Django:
```powershell
kubectl logs -n django-app deployment/django-deployment --tail=200
```

2. Убедитесь, что миграции выполнены:
```powershell
kubectl exec -it deployment/django-deployment -n django-app -- python manage.py migrate
```

3. Проверьте подключение к базе данных:
```powershell
kubectl logs -n django-app deployment/postgres-deployment --tail=50
```

