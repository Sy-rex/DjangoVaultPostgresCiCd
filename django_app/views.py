import socket
import psycopg2
import sys
import platform
from datetime import datetime
from django.http import JsonResponse
from django.conf import settings
from django.views.decorators.csrf import csrf_exempt
from django.views import View
from django.utils.decorators import method_decorator
from .models import Task
import json


def api_info(request):
    hostname = socket.gethostname()
    now = datetime.utcnow().isoformat() + "Z"

    db_status = "ok"
    try:
        conn = psycopg2.connect(
            dbname=settings.DATABASES["default"]["NAME"],
            user=settings.DATABASES["default"]["USER"],
            password=settings.DATABASES["default"]["PASSWORD"],
            host=settings.DATABASES["default"]["HOST"],
            port=settings.DATABASES["default"]["PORT"],
            connect_timeout=2,
        )
        conn.close()
    except Exception as e:
        db_status = f"error: {e}"

    total_tasks = Task.objects.count()
    tasks_by_status = {
        "pending": Task.objects.filter(status="pending").count(),
        "in_progress": Task.objects.filter(status="in_progress").count(),
        "completed": Task.objects.filter(status="completed").count(),
    }

    try:
        ip_address = socket.gethostbyname(hostname)
    except:
        ip_address = "unknown"

    return JsonResponse({
        "service": "django-task-manager",
        "version": "1.0.0",
        "hostname": hostname,
        "ip_address": ip_address,
        "time": now,
        "system": {
            "platform": platform.system(),
            "python_version": f"{sys.version_info.major}.{sys.version_info.minor}.{sys.version_info.micro}",
            "django_version": "4.2.7"
        },
        "database": {
            "name": str(settings.DATABASES['default']['NAME']),
            "user": str(settings.DATABASES['default']['USER']),
            "host": str(settings.DATABASES['default']['HOST']),
            "port": str(settings.DATABASES['default']['PORT']),
            "engine": settings.DATABASES['default']['ENGINE'].split('.')[-1],
            "status": db_status
        },
        "statistics": {
            "total_tasks": total_tasks,
            "tasks_by_status": tasks_by_status
        },
        "endpoints": {
            "health_check": "/health/",
            "api_info": "/api/",
            "tasks": "/tasks/"
        }
    })


def health(request):
    return JsonResponse({"status": "ok"})


@method_decorator(csrf_exempt, name='dispatch')
class TasksView(View):
    def get(self, request):
        tasks = Task.objects.all().order_by('-created_at')

        if 'text/html' in request.META.get('HTTP_ACCEPT', ''):
            from django.shortcuts import render
            context = {
                'tasks': tasks,
                'total_tasks': tasks.count(),
                'pending_count': tasks.filter(status='pending').count(),
                'in_progress_count': tasks.filter(status='in_progress').count(),
                'completed_count': tasks.filter(status='completed').count(),
            }
            return render(request, 'tasks.html', context)

        data = [
            {
                "id": t.id,
                "title": t.title,
                "description": t.description,
                "status": t.status,
                "created_at": t.created_at.isoformat(),
                "updated_at": t.updated_at.isoformat()
            }
            for t in tasks[:20]
        ]
        return JsonResponse({"tasks": data})

    def post(self, request):
        try:
            body = json.loads(request.body)
            title = body.get("title")
            if not title:
                return JsonResponse({"error": "title field required"}, status=400)

            description = body.get("description", "")
            status = body.get("status", "pending")

            if status not in ['pending', 'in_progress', 'completed']:
                return JsonResponse({"error": "invalid status value"}, status=400)

            task = Task.objects.create(
                title=title,
                description=description,
                status=status
            )
            return JsonResponse({
                "id": task.id,
                "title": task.title,
                "description": task.description,
                "status": task.status,
                "created_at": task.created_at.isoformat(),
                "updated_at": task.updated_at.isoformat()
            }, status=201)
        except json.JSONDecodeError:
            return JsonResponse({"error": "invalid JSON"}, status=400)

