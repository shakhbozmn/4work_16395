from django.contrib import messages
from django.contrib.auth import login, logout
from django.contrib.auth.decorators import login_required
from django.shortcuts import get_object_or_404, redirect, render
from django.urls import reverse_lazy
from django.views.generic import CreateView
from django.views.generic.base import View

from .forms import CustomAuthenticationForm, CustomUserCreationForm, ProfileForm
from .models import Profile, User


class RegisterView(CreateView):
    model = User
    form_class = CustomUserCreationForm
    template_name = "auth/register.html"
    success_url = reverse_lazy("accounts:login")

    def form_valid(self, form):
        response = super().form_valid(form)
        login(self.request, self.object)
        # Create profile for new user
        Profile.objects.get_or_create(user=self.object)
        messages.success(self.request, "Registration successful! Welcome to 4work.")
        return response


class LoginView(View):
    def get(self, request):
        form = CustomAuthenticationForm()
        return render(request, "auth/login.html", {"form": form})

    def post(self, request):
        form = CustomAuthenticationForm(request, data=request.POST)
        if form.is_valid():
            login(request, form.get_user())
            messages.success(request, "Login successful!")
            next_url = request.GET.get("next", reverse_lazy("home"))
            return redirect(next_url)
        return render(request, "auth/login.html", {"form": form})


class LogoutView(View):
    def get(self, request):
        logout(request)
        messages.success(request, "You have been logged out.")
        return redirect("accounts:login")


@login_required
def profile_detail(request, username):
    user = get_object_or_404(User, username=username)
    profile = get_object_or_404(Profile, user=user)
    context = {
        "profile_user": user,
        "profile": profile,
    }
    return render(request, "accounts/profile_detail.html", context)


@login_required
def profile_update(request):
    profile = get_object_or_404(Profile, user=request.user)

    if request.method == "POST":
        form = ProfileForm(request.POST, request.FILES, instance=profile)
        if form.is_valid():
            form.save()
            messages.success(request, "Profile updated successfully!")
            return redirect("accounts:profile_detail", username=request.user.username)
    else:
        form = ProfileForm(instance=profile)

    return render(request, "accounts/profile_update.html", {"form": form})
