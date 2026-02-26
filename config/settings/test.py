"""Test settings — extends development and uses Postgres."""
import os

from config.settings.development import *  # noqa: F401, F403

DATABASES = {
    "default": {
        "ENGINE": "django.db.backends.postgresql",
        "NAME": os.environ.get("DB_NAME", "test_4work_db"),
        "USER": os.environ.get("DB_USER", "test_user"),
        "PASSWORD": os.environ.get("DB_PASSWORD", "test_password"),
        "HOST": os.environ.get("DB_HOST", "localhost"),
        "PORT": os.environ.get("DB_PORT", "5432"),
    }
}

# Silence password hashing to speed up tests
PASSWORD_HASHERS = [
    "django.contrib.auth.hashers.MD5PasswordHasher",
]
