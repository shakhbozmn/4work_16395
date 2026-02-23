#!/bin/bash

# Backup script for 4work application

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
BACKUP_FILE="$BACKUP_DIR/4work_backup_$DATE.sql"

echo -e "${GREEN}================================${NC}"
echo -e "${GREEN}4work Backup Script${NC}"
echo -e "${GREEN}================================${NC}"
echo ""

# Check if running as root
if [ "$EUID" -ne 0 ]; then
    print_message "${RED}This script must be run as a non-root user"
    create_backup_dir
fi

create_backup_dir() {
    if [ ! -d "$BACKUP_DIR" ]; then
        mkdir -p "$BACKUP_DIR"
        echo -e "${YELLOW}Created backup directory: $BACKUP_DIR${NC}"
    fi
}

# Navigate to project directory
cd "$PROJECT_DIR" || exit 1

print_message "${YELLOW}Creating backup directory...${NC}"
create_backup_dir

print_message "${YELLOW}Step 1: Dumping PostgreSQL database...${NC}"
docker-compose exec -T postgres pg_dump -U 4work_prod_user 4work_prod_db > "$BACKUP_FILE" || exit 1

print_message "${YELLOW}Step 2: Compressing backup...${NC}"
gzip "$BACKUP_FILE" || exit 1

print_message "${YELLOW}Step 3: Calculating backup size...${NC}"
SIZE=$(du -h "$BACKUP_FILE.gz" | cut -f1)
print_message "${YELLOW}Backup size: $SIZE${NC}"

print_message "${GREEN}================================${NC}"
print_message "${GREEN}Backup completed: $BACKUP_FILE.gz${NC}"
print_message "${GREEN}================================${NC}"

# Cleanup old backups (keep last 7 days)
print_message "${YELLOW}Cleaning up old backups (keeping last 7 days)...${NC}"
find "$BACKUP_DIR" -name "4work_backup_*.sql.gz" -mtime +7 -delete

print_message "${GREEN}Done!${NC}"
