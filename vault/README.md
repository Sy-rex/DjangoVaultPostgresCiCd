# Настройка HashiCorp Vault для Django приложения

Этот каталог содержит скрипты и конфигурацию для установки и настройки HashiCorp Vault в Kubernetes кластере.

## Предварительные требования

- Kubernetes кластер (minikube, kind, или другой)
- Helm 3.x установлен
- kubectl настроен для работы с кластером

## Быстрый старт

### Вариант 1: Полная установка одним скриптом (рекомендуется)

Выполните единый скрипт, который установит и настроит всё автоматически:

```bash
chmod +x vault/install-and-configure.sh
./vault/install-and-configure.sh
```

Этот скрипт выполнит все шаги автоматически:
1. Установку Vault через Helm
2. Настройку KV движка
3. Запись секретов
4. Создание политик доступа

### Вариант 2: Пошаговая установка

#### 1. Установка Vault

Выполните скрипт установки:

```bash
chmod +x vault/setup-vault.sh
./vault/setup-vault.sh
```

Этот скрипт:
- Добавляет Helm репозиторий HashiCorp
- Создает namespace `vault`
- Устанавливает Vault в Dev режиме (без TLS, данные в памяти)

#### 2. Настройка KV движка и секретов

После установки настройте Vault:

```bash
chmod +x vault/configure-vault.sh
./vault/configure-vault.sh
```

Этот скрипт:
- Включает KV движок версии 2 по пути `secret`
- Записывает секреты для Django приложения:
  - `db_name`: django_prod
  - `db_user`: django_user
  - `db_password`: SuperSecret123!
  - `secret_key`: very-secret-key-prod
- Создает политику доступа `django-app`

### 3. Проверка секретов

Получить секреты можно командой:

```bash
chmod +x vault/get-secrets.sh
./vault/get-secrets.sh
```

Или вручную:

```bash
kubectl exec -it vault-0 -n vault -- vault kv get secret/django-app/database
```

## Ручная настройка

Если вы предпочитаете настраивать вручную:

### 1. Установка через Helm

```bash
helm repo add hashicorp https://helm.hashicorp.com
helm repo update
kubectl create namespace vault
helm install vault hashicorp/vault \
  --namespace vault \
  --set "server.dev.enabled=true" \
  --set "global.tlsDisable=true"
```

### 2. Настройка внутри контейнера

```bash
# Заходим в контейнер
kubectl exec -it vault-0 -n vault -- /bin/sh

# Включаем KV движок версии 2
vault secrets enable -path=secret kv-v2

# Записываем секреты
vault kv put secret/django-app/database \
  db_name="django_prod" \
  db_user="django_user" \
  db_password="SuperSecret123!" \
  secret_key="very-secret-key-prod"

# Проверяем
vault kv get secret/django-app/database

# Создаем политику
vault policy write django-app - <<EOF
path "secret/data/django-app/*" {
  capabilities = ["read"]
}
EOF

exit
```

## Дополнительные скрипты

### Настройка политик

```bash
chmod +x vault/setup-policies.sh
./vault/setup-policies.sh
```

Создает дополнительные политики:
- `django-app` - чтение секретов Django приложения
- `admin-read` - чтение всех секретов
- `admin-full` - полный доступ ко всем секретам

## Структура секретов

Секреты хранятся по пути: `secret/django-app/database`

Содержимое:
- `db_name` - имя базы данных
- `db_user` - пользователь базы данных
- `db_password` - пароль базы данных
- `secret_key` - секретный ключ Django

## Политики доступа

### Политика django-app

Разрешает чтение секретов Django приложения:

```hcl
path "secret/data/django-app/*" {
  capabilities = ["read"]
}
```

## Интеграция с Django

Для использования секретов из Vault в Django приложении можно:

1. Использовать Vault Agent для автоматической инъекции секретов
2. Использовать Kubernetes Secrets, синхронизированные из Vault
3. Использовать библиотеку `hvac` для прямого доступа к Vault API

## Важные замечания

⚠️ **Dev режим**: Текущая конфигурация использует Dev режим Vault, который:
- Не использует TLS
- Хранит данные в памяти (данные теряются при перезапуске)
- Не подходит для production окружения

Для production необходимо:
- Настроить TLS
- Использовать постоянное хранилище (Consul, etcd, или другое)
- Настроить HA (High Availability) режим

## Полезные команды

```bash
# Проверить статус Vault
kubectl get pods -n vault

# Посмотреть логи Vault
kubectl logs -f vault-0 -n vault

# Получить список секретов
kubectl exec -it vault-0 -n vault -- vault kv list secret/

# Получить список политик
kubectl exec -it vault-0 -n vault -- vault policy list

# Удалить Vault
helm uninstall vault -n vault
kubectl delete namespace vault
```

## Troubleshooting

### Vault pod не запускается

```bash
kubectl describe pod vault-0 -n vault
kubectl logs vault-0 -n vault
```

### Не могу подключиться к Vault

Убедитесь, что pod в состоянии Ready:
```bash
kubectl get pods -n vault
```

### Секреты не читаются

Проверьте политику доступа:
```bash
kubectl exec -it vault-0 -n vault -- vault policy read django-app
```

