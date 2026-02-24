#!/bin/bash
# deploy.sh — run on the Azure VM via CI/CD SSH step
# Usage: cd /opt/4work && bash deploy.sh
set -euo pipefail

echo "==> Pulling latest images..."
docker compose -f docker-compose.yml --env-file .env.production pull

echo "==> Starting containers (zero-downtime replace)..."
docker compose -f docker-compose.yml --env-file .env.production up -d --remove-orphans

echo "==> Running database migrations..."
docker compose -f docker-compose.yml --env-file .env.production exec -T web python manage.py migrate --noinput

echo "==> Collecting static files..."
docker compose -f docker-compose.yml --env-file .env.production exec -T web python manage.py collectstatic --noinput

echo "==> Pruning unused images..."
docker image prune -f

echo "==> Deployment complete."
