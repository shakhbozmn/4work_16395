#!/bin/bash
set -e

echo "========================================="
echo "Starting Deployment Process"
echo "========================================="

# Pull latest changes
echo "Pulling latest code from git..."
git pull origin ci_cd_fix

# Stop all running containers
echo "Stopping existing containers..."
docker compose down

# Build the image locally
echo "Building Docker image..."
docker compose build --no-cache web

# Start services
echo "Starting services..."
docker compose up -d

# Wait for services to be healthy
echo "Waiting for services to be healthy..."
sleep 10

# Check container status
echo "========================================="
echo "Container Status:"
docker compose ps

echo "========================================="
echo "Recent logs from app container:"
docker logs --tail 50 4work_app

echo "========================================="
echo "Deployment completed!"
echo "========================================="