#!/bin/bash
# Manual deployment script for Azure VM
# Run this on the server: bash deploy-manual.sh

set -e

echo "==> 1. Pulling latest changes from repository..."
git pull origin staging

echo "==> 2. Stopping containers..."
docker compose -f docker-compose.yml --env-file .env.production down

echo "==> 3. Pulling latest Docker images..."
docker compose -f docker-compose.yml --env-file .env.production pull

echo "==> 4. Building and starting containers..."
docker compose -f docker-compose.yml --env-file .env.production up -d --build --remove-orphans

echo "==> 5. Waiting for services to start..."
sleep 10

echo "==> 6. Running migrations..."
docker compose -f docker-compose.yml --env-file .env.production exec -T web python manage.py migrate --noinput

echo "==> 7. Collecting static files..."
docker compose -f docker-compose.yml --env-file .env.production exec -T web python manage.py collectstatic --noinput --clear

echo "==> 8. Checking container status..."
docker compose -f docker-compose.yml --env-file .env.production ps

echo "==> 9. Checking logs for errors..."
docker compose -f docker-compose.yml --env-file .env.production logs --tail=50 web nginx

echo ""
echo "==> Deployment complete!"
echo "==> Check the site: https://dscc-shahbozms.polandcentral.cloudapp.azure.com/"
echo ""
echo "To debug further, run:"
echo "  docker compose logs -f web"
echo "  docker compose logs -f nginx"
