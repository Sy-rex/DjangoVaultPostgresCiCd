from django.shortcuts import render, redirect
from .models import TodoItem
from .forms import TodoForm

def todo_list(request):
    todos = TodoItem.objects.all().order_by('-created_at')
    form = TodoForm()
    return render(request, 'todo/todo_list.html', {'todos': todos, 'form': form})

def add_todo(request):
    if request.method == 'POST':
        form = TodoForm(request.POST)
        if form.is_valid():
            form.save()
    return redirect('todo_list')

def complete_todo(request, pk):
    todo = TodoItem.objects.get(pk=pk)
    todo.completed = not todo.completed
    todo.save()
    return redirect('todo_list')

def delete_todo(request, pk):
    TodoItem.objects.get(pk=pk).delete()
    return redirect('todo_list')
