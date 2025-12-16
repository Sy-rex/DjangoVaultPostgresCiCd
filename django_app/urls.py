from django.contrib import admin
from django.urls import path, include
from django.http import HttpResponse
from django_app.views import api_info, TasksView, TaskDetailView
import socket

def hostname_view(request):
    return HttpResponse(f"Hello! Served by Pod: {socket.gethostname()}")

urlpatterns = [
    path('admin/', admin.site.urls),
    path('', hostname_view),
    path('health/', lambda r: HttpResponse("OK")),
    path('prometheus/', include('django_prometheus.urls')),
    path("api/", api_info, name="api"),
    path("tasks/", TasksView.as_view(), name="tasks"),
    path("tasks/<int:task_id>/", TaskDetailView.as_view(), name="task_detail"),
]
