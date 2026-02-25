#!/bin/bash
# Quick fix for permission issues with static files
# Run this on the server if you get permission errors

echo "==> Fixing static files permissions..."

# Option 1: Fix permissions (recommended)
docker compose -f docker-compose.yml --env-file .env.production exec --user root web chown -R 1000:1000 /app/staticfiles /app/media

echo "==> Collecting static files again..."
docker compose -f docker-compose.yml --env-file .env.production exec web python manage.py collectstatic --noinput

echo "==> Done! Static files should now work."
