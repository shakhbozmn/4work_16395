"""
Settings initialization - automatically loads development or production settings
based on the DJANGO_SETTINGS_MODULE environment variable.

For development: DJANGO_SETTINGS_MODULE=config.settings.development
For production: DJANGO_SETTINGS_MODULE=config.settings.production

If DJANGO_SETTINGS_MODULE is set to config.settings, defaults to development.
"""

import os

# Get the Django settings module from environment
settings_module = os.environ.get('DJANGO_SETTINGS_MODULE', 'config.settings')

# If it's just 'config.settings', default to development
if settings_module == 'config.settings':
    from .development import *
else:
    # Otherwise, the specific module will be loaded by Django
    pass
