# Быстрое решение проблемы с namespace

Если вы получили ошибку:
```
Error: INSTALLATION FAILED: unable to continue with install: Namespace "django-app" in namespace "" exists and cannot be imported into the current release
```

## Решение (выберите один вариант):

### Вариант 1: Обновить существующие namespace (рекомендуется)

**Windows PowerShell:**
```powershell
.\helm\fix-namespace.ps1
```

**Linux/Mac:**
```bash
chmod +x helm/fix-namespace.sh
./helm/fix-namespace.sh
```

**Или вручную выполните команды:**
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

После этого запустите:
```bash
helm install django-app ./helm/django-app
```

### Вариант 2: Удалить и пересоздать namespace

**ВНИМАНИЕ**: Это удалит все ресурсы в namespace!

```bash
kubectl delete namespace django-app vault
helm install django-app ./helm/django-app
```

