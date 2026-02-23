"""
Views for the config app.
"""

from django.http import JsonResponse
from django.views import View


class HealthCheckView(View):
    """
    Simple health check endpoint that returns JSON response.
    Used by monitoring tools and deployment scripts.
    """

    def get(self, request):
        return JsonResponse({"status": "healthy", "service": "4work"}, status=200)
