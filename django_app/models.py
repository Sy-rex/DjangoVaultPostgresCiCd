from django.db import models

class Task(models.Model):
    STATUS_CHOICES = [
        ('pending', 'Ожидает'),
        ('in_progress', 'В работе'),
        ('completed', 'Выполнено'),
    ]

    title = models.CharField(max_length=200)
    description = models.TextField(blank=True, default='')
    status = models.CharField(max_length=20, choices=STATUS_CHOICES, default='pending')
    created_at = models.DateTimeField(auto_now_add=True)
    updated_at = models.DateTimeField(auto_now=True)

    def __str__(self):
        return f"{self.title} [{self.status}]"
