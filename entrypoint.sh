#!/bin/bash
set -euo pipefail

DB_HOST=${DB_HOST:-db}
DB_PORT=${DB_PORT:-5432}

echo "=================================="
echo "Starting entrypoint script..."
echo "=================================="

# Wait for database to be ready
echo "Waiting for PostgreSQL..."
while ! nc -z "$DB_HOST" "$DB_PORT"; do
  sleep 1
done
echo "PostgreSQL is ready!"

# Fix ownership of volumes (running as root initially)
echo "Fixing volume permissions..."
chown -R appuser:appuser /app/staticfiles /app/media

# Run migrations as appuser
echo "Running migrations..."
gosu appuser python manage.py migrate --noinput

# Collect static files as appuser
echo "Collecting static files..."
gosu appuser python manage.py collectstatic --noinput --clear

echo "=================================="
echo "Starting Gunicorn as appuser..."
echo "=================================="

# Print diagnostic info
echo "=== Gunicorn Diagnostic Info ==="
echo "Gunicorn version:"
gunicorn --version
echo "Running as user: $(whoami)"
echo "=== End Diagnostic Info ==="

# Execute gunicorn as appuser
exec gosu appuser gunicorn config.wsgi:application \
    --bind 0.0.0.0:8000 \
    --workers 3 \
    --timeout 120 \
    --worker-tmp-dir /dev/shm \
    --access-logfile - \
    --error-logfile - \
    --preload