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

echo "Ensuring db and nginx are running..."
docker compose up -d db nginx

echo "Redeploying web service with zero downtime..."
docker compose up -d --no-deps --force-recreate web

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