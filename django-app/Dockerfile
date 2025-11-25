FROM python:3.10-slim

ENV PYTHONUNBUFFERED 1
WORKDIR /app

# Установка зависимостей
COPY requirements.txt .
RUN pip install --no-cache-dir -r requirements.txt

# Копирование приложения
COPY . .

# Запуск сервера
CMD ["gunicorn", "myproject.wsgi:application", "--bind", "0.0.0.0:8000"]
