from django import forms
from .models import TodoItem

class TodoForm(forms.ModelForm):
    class Meta:
        model = TodoItem
        fields = ['title']
        widgets = {
            'title': forms.TextInput(attrs={'class': 'form-control', 'placeholder': 'Add a new task...'})
        }
