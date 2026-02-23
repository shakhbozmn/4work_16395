#!/bin/bash

# Rollback script for 4work application

set -e # Exit on error

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Configuration
PROJECT_DIR="/opt/4work"
BACKUP_DIR="/opt/backups"
DATE=$(date +%Y%m%d_%H%M%S)

echo -e "${GREEN}================================${NC}"
echo -e "${GREEN}4work Rollback Script${NC}"
echo -e "${GREEN}================================${NC}"
echo ""

# Check if running as root
if [ "$EUID" -ne 0 ]; then
    print_message "${RED}This script must be run as a non-root user"
    exit 1
fi

# Navigate to project directory
cd "$PROJECT_DIR" || exit 1

print_message "${YELLOW}Step 1: Stopping containers...${NC}"
docker-compose down || exit 1

print_message "${YELLOW}Step 2: Rolling back to previous version...${NC}"

# Find previous image version
PREVIOUS_IMAGE=$(docker images --format "{{.Repository}}:{{.Tag}}" | grep 4work | tail -1 | awk '{print $2}')

if [ -z "$PREVIOUS_IMAGE" ]; then
    print_message "${RED}No previous image found${NC}"
    exit 1
fi

print_message "${YELLOW}Previous version: $PREVIOUS_IMAGE${NC}"
print_message "${YELLOW}Step 3: Starting previous version...${NC}"

# Update docker-compose to use previous image
sed -i "s|image: 4work:latest|image: 4work:$PREVIOUS_IMAGE|" docker-compose.yml > docker-compose.yml.tmp
mv docker-compose.yml.tmp docker-compose.yml || exit 1

print_message "${YELLOW}Step 4: Starting containers...${NC}"
docker-compose up -d || exit 1

# Wait for application to be healthy
sleep 15

# Check health
if ./scripts/healthcheck.sh; then
    print_message "${GREEN}✓ Application is healthy${NC}"
else
    print_message "${RED}✗ Application health check failed${NC}"
    print_message "${YELLOW}Checking logs...${NC}"
    docker-compose logs --tail=50 django
    exit 1
fi

print_message "${GREEN}================================${NC}"
print_message "${GREEN}Rollback completed successfully!${NC}"
print_message "${GREEN}================================${NC}"
print_message ""
print_message "${YELLOW}If issues persist, restore from backup: $BACKUP_DIR/4work_backup_$DATE.sql.gz${NC}"
