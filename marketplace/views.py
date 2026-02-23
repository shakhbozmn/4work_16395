from django.shortcuts import render, redirect, get_object_or_404
from django.contrib.auth.decorators import login_required
from django.contrib import messages
from django.views.generic import ListView, DetailView, CreateView, UpdateView, DeleteView
from django.urls import reverse_lazy
from django.db.models import Q
from .models import Project, Category, Application
from .forms import ProjectForm, ApplicationForm


class ProjectListView(ListView):
    model = Project
    template_name = 'marketplace/project_list.html'
    context_object_name = 'projects'
    paginate_by = 12

    def get_queryset(self):
        queryset = Project.objects.filter(status='open').select_related('client', 'category')
        
        # Search
        search_query = self.request.GET.get('search')
        if search_query:
            queryset = queryset.filter(
                Q(title__icontains=search_query) |
                Q(description__icontains=search_query)
            )
        
        # Category filter
        category_id = self.request.GET.get('category')
        if category_id:
            queryset = queryset.filter(category_id=category_id)
        
        return queryset

    def get_context_data(self, **kwargs):
        context = super().get_context_data(**kwargs)
        context['categories'] = Category.objects.all()
        context['search_query'] = self.request.GET.get('search', '')
        context['selected_category'] = self.request.GET.get('category', '')
        return context


class ProjectDetailView(DetailView):
    model = Project
    template_name = 'marketplace/project_detail.html'
    context_object_name = 'project'

    def get_queryset(self):
        return Project.objects.select_related('client', 'category', 'assigned_freelancer')

    def get_context_data(self, **kwargs):
        context = super().get_context_data(**kwargs)
        project = self.object
        context['applications'] = project.applications.select_related('freelancer')
        context['has_applied'] = False
        
        if self.request.user.is_authenticated:
            context['has_applied'] = project.applications.filter(
                freelancer=self.request.user
            ).exists()
        
        return context


@login_required
def project_create(request):
    if request.method == 'POST':
        form = ProjectForm(request.POST)
        if form.is_valid():
            project = form.save(commit=False)
            project.client = request.user
            project.save()
            messages.success(request, 'Project created successfully!')
            return redirect('marketplace:project_detail', pk=project.pk)
    else:
        form = ProjectForm()
    
    return render(request, 'marketplace/project_form.html', {
        'form': form,
        'title': 'Create Project',
        'action': 'Create',
    })


@login_required
def project_update(request, pk):
    project = get_object_or_404(Project, pk=pk)
    
    # Only the client who created the project can edit it
    if project.client != request.user:
        messages.error(request, 'You do not have permission to edit this project.')
        return redirect('marketplace:project_detail', pk=project.pk)
    
    if request.method == 'POST':
        form = ProjectForm(request.POST, instance=project)
        if form.is_valid():
            form.save()
            messages.success(request, 'Project updated successfully!')
            return redirect('marketplace:project_detail', pk=project.pk)
    else:
        form = ProjectForm(instance=project)
    
    return render(request, 'marketplace/project_form.html', {
        'form': form,
        'project': project,
        'title': 'Update Project',
        'action': 'Update',
    })


@login_required
def project_delete(request, pk):
    project = get_object_or_404(Project, pk=pk)
    
    # Only the client who created the project can delete it
    if project.client != request.user:
        messages.error(request, 'You do not have permission to delete this project.')
        return redirect('marketplace:project_detail', pk=project.pk)
    
    if request.method == 'POST':
        project.delete()
        messages.success(request, 'Project deleted successfully!')
        return redirect('marketplace:project_list')
    
    return render(request, 'marketplace/project_confirm_delete.html', {'project': project})


class CategoryListView(ListView):
    model = Category
    template_name = 'marketplace/category_list.html'
    context_object_name = 'categories'


class CategoryDetailView(DetailView):
    model = Category
    template_name = 'marketplace/category_detail.html'
    context_object_name = 'category'

    def get_context_data(self, **kwargs):
        context = super().get_context_data(**kwargs)
        context['projects'] = self.object.projects.filter(
            status='open'
        ).select_related('client')
        return context


@login_required
def application_create(request, project_pk):
    project = get_object_or_404(Project, pk=project_pk)
    
    # Only freelancers can apply
    if request.user.role != 'freelancer':
        messages.error(request, 'Only freelancers can apply to projects.')
        return redirect('marketplace:project_detail', pk=project_pk)
    
    # Check if already applied
    if project.applications.filter(freelancer=request.user).exists():
        messages.error(request, 'You have already applied to this project.')
        return redirect('marketplace:project_detail', pk=project_pk)
    
    if request.method == 'POST':
        form = ApplicationForm(request.POST)
        if form.is_valid():
            application = form.save(commit=False)
            application.project = project
            application.freelancer = request.user
            application.save()
            messages.success(request, 'Application submitted successfully!')
            return redirect('marketplace:project_detail', pk=project.pk)
    else:
        form = ApplicationForm()
    
    return render(request, 'marketplace/application_form.html', {
        'form': form,
        'project': project,
    })


@login_required
def application_accept(request, pk):
    application = get_object_or_404(Application, pk=pk)
    project = application.project
    
    # Only project owner can accept applications
    if project.client != request.user:
        messages.error(request, 'You do not have permission to accept this application.')
        return redirect('marketplace:project_detail', pk=project.pk)
    
    if project.status != 'open':
        messages.error(request, 'This project is no longer accepting applications.')
        return redirect('marketplace:project_detail', pk=project.pk)
    
    # Accept application
    application.status = 'accepted'
    application.save()
    
    # Update project
    project.assigned_freelancer = application.freelancer
    project.status = 'assigned'
    project.save()
    
    # Reject other applications
    project.applications.exclude(pk=pk).update(status='rejected')
    
    messages.success(request, 'Application accepted successfully!')
    return redirect('marketplace:project_detail', pk=project.pk)


@login_required
def application_reject(request, pk):
    application = get_object_or_404(Application, pk=pk)
    project = application.project
    
    # Only project owner can reject applications
    if project.client != request.user:
        messages.error(request, 'You do not have permission to reject this application.')
        return redirect('marketplace:project_detail', pk=project.pk)
    
    application.status = 'rejected'
    application.save()
    
    messages.success(request, 'Application rejected.')
    return redirect('marketplace:project_detail', pk=project.pk)
