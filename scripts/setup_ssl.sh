#!/bin/bash

# SSL certificate setup script for 4work application

set -e # Exit on error

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

echo -e "${GREEN}================================${NC}"
echo -e "${GREEN}4work SSL Setup Script${NC}"
echo -e "${GREEN}================================${NC}"
echo ""

# Check if running as root
if [ "$EUID" -ne 0 ]; then
    print_message "${RED}This script must be run as root"
    exit 1
fi

# Check if domain is provided
if [ -z "$1" ]; then
    print_message "${RED}Usage: $0 <domain.uz>${NC}"
    exit 1
fi

DOMAIN=$1

print_message "${YELLOW}Installing Certbot...${NC}"
sudo apt-get update
sudo apt-get install -y certbot python3-certbot-nginx || exit 1

print_message "${YELLOW}Obtaining SSL certificate for $DOMAIN${NC}"
sudo certbot --nginx -d $DOMAIN --agree-tos --email your-email@example.com --non-interactive || exit 1

print_message "${YELLOW}Setting up SSL directories...${NC}"
sudo mkdir -p /etc/nginx/ssl
sudo cp /etc/letsencrypt/live/$DOMAIN/fullchain.pem /etc/nginx/ssl/
sudo cp /etc/letsencrypt/live/$DOMAIN/privkey.pem /etc/nginx/ssl/
sudo chown -R www-data:www-data /etc/nginx/ssl/ || exit 1

print_message "${GREEN}================================${NC}"
print_message "${GREEN}SSL certificate installed successfully!${NC}"
print_message "${GREEN}================================${NC}"
print_message ""
print_message "${YELLOW}Files location:${NC}"
print_message "${YELLOW}  - Certificate: /etc/nginx/ssl/fullchain.pem${NC}"
print_message "${YELLOW}  - Private Key: /etc/nginx/ssl/infokey.pem${NC}"
print_message ""
print_message "${YELLOW}Next steps:${NC}"
print_message "${YELLOW}1. Uncomment SSL server block in nginx/nginx.conf${NC}"
print_message "${YELLOW}2. Restart nginx service: docker-compose restart nginx${NC}"
print_message "${YELLOW}3. Test HTTPS: curl -f https://$DOMAIN${NC}"
print_message "${GREEN}================================${NC}"
