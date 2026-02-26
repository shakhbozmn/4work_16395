#!/bin/bash

set -euo pipefail

echo "========================================="
echo "Starting Deployment Process"
echo "========================================="

if [[ -z "${DOCKERHUB_USERNAME:-}" ]]; then
	echo "ERROR: DOCKERHUB_USERNAME environment variable is not set."
	exit 1
fi

echo "Pulling latest code from git..."
git pull origin main

echo "Fetching latest Docker image..."
docker compose pull web

echo "Redeploying web service with zero downtime..."
docker compose up -d --no-deps --force-recreate web

echo "Running database migrations..."
docker compose exec web python manage.py migrate --noinput

echo "Collecting static files..."
docker compose exec web python manage.py collectstatic --noinput

echo "Waiting for the application health check..."
sleep 10

echo "========================================="
echo "Container Status:"
docker compose ps

echo "========================================="
echo "Recent logs from app container:"
docker logs --tail 50 4work_app

echo "========================================="
echo "Deployment completed!"
echo "========================================="