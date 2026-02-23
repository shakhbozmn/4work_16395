#!/bin/bash

set -e  # Exit on error

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Configuration
PROJECT_DIR="/opt/4work"
DOCKER_COMPOSE="docker-compose"
BACKUP_DIR="/opt/backups"

echo -e "${GREEN}================================${NC}"
echo -e "${GREEN} 4work Deployment Script${NC}"
echo -e "${GREEN}================================${NC}"
echo ""

# Function to print colored messages
print_message() {
    local color=$1
    shift
    echo -e "${color}$1${NC}"
}

# Check if running as root
if [ "$EUID" -ne 0 ]; then
    print_message "${RED}This script must be run as a non-root user"
    exit 1
fi

# Navigate to project directory
cd "$PROJECT_DIR" || exit 1

print_message "${YELLOW}Step 1: Pulling latest Docker images...${NC}"
docker-compose pull || exit 1

print_message "${YELLOW}Step 2: Stopping old containers...${NC}"
docker-compose down || exit 1

print_message "${YELLOW}Step 3: Starting new containers...${NC}"
docker-compose up -d || exit 1

print_message "${YELLOW}Step 4: Waiting for application to be healthy...${NC}"
sleep 10

# Check health
if ./scripts/healthcheck.sh; then
    print_message "${GREEN}✓ Application is healthy${NC}"
else
    print_message "${RED}✗ Application health check failed${NC}"
    print_message "${YELLOW}Checking logs...${NC}"
    docker-compose logs --tail=50 django
    exit 1
fi

print_message "${YELLOW}Step 5: Running database migrations...${NC}"
docker-compose exec -T django python manage.py migrate --noinput || exit 1

print_message "${YELLOW}Step 6: Collecting static files...${NC}"
docker-compose exec -T django python manage.py collectstatic --noinput || exit 1

print_message "${GREEN}================================${NC}"
print_message "${GREEN}Deployment completed successfully!${NC}"
print_message "${GREEN}================================${NC}"
print_message ""
print_message "${YELLOW}Application is available at: http://yourdomain.uz${NC}"
print_message "${YELLOW}Admin panel: https://yourdomain.uz/admin${NC}"
print_message "${YELLOW}To view logs: docker-compose logs -f${NC}"
