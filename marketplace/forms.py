from django import forms
from .models import Project, Application


class ProjectForm(forms.ModelForm):
    class Meta:
        model = Project
        fields = ('title', 'description', 'budget', 'deadline', 'category')
        widgets = {
            'title': forms.TextInput(attrs={'class': 'form-input'}),
            'description': forms.Textarea(attrs={'rows': 6, 'class': 'form-input'}),
            'budget': forms.NumberInput(attrs={'class': 'form-input', 'step': '0.01'}),
            'deadline': forms.DateInput(attrs={'class': 'form-input', 'type': 'date'}),
            'category': forms.Select(attrs={'class': 'form-select'}),
        }

    def __init__(self, *args, **kwargs):
        super().__init__(*args, **kwargs)
        self.fields['category'].queryset = self.fields['category'].queryset.order_by('name')
        self.fields['category'].empty_label = "Select a category"


class ApplicationForm(forms.ModelForm):
    class Meta:
        model = Application
        fields = ('cover_letter', 'proposed_timeline', 'proposed_budget')
        widgets = {
            'cover_letter': forms.Textarea(attrs={'rows': 6, 'class': 'form-input'}),
            'proposed_timeline': forms.NumberInput(attrs={'class': 'form-input'}),
            'proposed_budget': forms.NumberInput(attrs={'class': 'form-input', 'step': '0.01'}),
        }
