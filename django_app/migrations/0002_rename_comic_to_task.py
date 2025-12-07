# Generated migration to convert Comic to Task

from django.db import migrations, models


class Migration(migrations.Migration):

    dependencies = [
        ('django_app', '0001_initial'),
    ]

    operations = [
        migrations.RenameModel(
            old_name='Comic',
            new_name='Task',
        ),
        migrations.RemoveField(
            model_name='task',
            name='author',
        ),
        migrations.AlterField(
            model_name='task',
            name='status',
            field=models.CharField(
                choices=[
                    ('pending', 'Ожидает'),
                    ('in_progress', 'В работе'),
                    ('completed', 'Выполнено')
                ],
                default='pending',
                max_length=20
            ),
        ),
    ]

