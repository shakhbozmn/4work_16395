# Deployment Troubleshooting Checklist

## Quick Deployment Steps on Azure Server:

```bash
# SSH into your Azure VM
ssh azureuser@dscc-shahbozms.polandcentral.cloudapp.azure.com

# Navigate to project directory
cd /opt/4work

# Pull latest changes from staging branch
git pull origin staging

# Rebuild and restart containers
docker compose down
docker compose up -d --build

# Check logs
docker compose logs -f
```

## Common Issues & Solutions:

### 1. Site Still Returns 301 Loop
**Check:**
```bash
# View Django logs for 301 responses
docker compose logs web | grep "301"

# Test health endpoint directly
docker compose exec web curl -I http://localhost:8000/health/

# Check if SECURE_SSL_REDIRECT is truly False
docker compose exec web python manage.py shell -c "from django.conf import settings; print('SSL_REDIRECT:', settings.SECURE_SSL_REDIRECT)"
```

### 2. Nginx Not Starting
**Check:**
```bash
# View nginx logs
docker compose logs nginx

# Test nginx config inside container
docker compose exec nginx nginx -t

# Check if nginx config file is mounted correctly
docker compose exec nginx cat /etc/nginx/nginx.conf
```

### 3. Site Not Accessible at All
**Check:**
```bash
# Check if containers are running
docker compose ps

# Check Azure NSG (Network Security Group) rules
# Port 80 and 443 must be open

# Check if nginx is listening
docker compose exec nginx netstat -tulpn | grep nginx

# Test from within server
curl -I http://localhost
curl -I http://localhost/health/
```

### 4. Environment Variables Not Loading
**Check:**
```bash
# Verify .env.production exists and has correct values
cat .env.production | grep -v PASSWORD

# Check what Django sees
docker compose exec web python manage.py shell -c "import os; print('DEBUG:', os.getenv('DEBUG')); print('ALLOWED_HOSTS:', os.getenv('ALLOWED_HOSTS'))"
```

### 5. Database Connection Issues
**Check:**
```bash
# Check database container
docker compose ps db

# Test database connection
docker compose exec web python manage.py check --database default
```

## Debug Commands:

```bash
# Get full logs from all services
docker compose logs --tail=100

# Follow logs in real-time
docker compose logs -f web nginx

# Check container health status
docker compose ps
docker inspect 4work_app | grep -A 10 Health
docker inspect 4work_nginx | grep -A 10 Health

# Execute command inside web container
docker compose exec web bash

# Check if files were updated
docker compose exec nginx ls -la /etc/nginx/
docker compose exec nginx cat /etc/nginx/nginx.conf | head -20
docker compose exec web grep "SECURE_SSL_REDIRECT" /app/config/settings.py
```

## Expected Behavior After Fix:

1. ✅ `docker compose logs web` should NOT show 301 responses for `/health/`
2. ✅ `curl http://localhost/health/` from inside server should return 200
3. ✅ `curl https://dscc-shahbozms.polandcentral.cloudapp.azure.com/health/` should return 200
4. ✅ nginx logs should show successful proxying without 301 loops

## If Still Not Working:

1. **Check if changes were pulled:**
   ```bash
   git log -1 --oneline
   git diff origin/staging
   ```

2. **Force rebuild containers:**
   ```bash
   docker compose down -v  # WARNING: removes volumes/data
   docker compose build --no-cache
   docker compose up -d
   ```

3. **Check Azure Load Balancer settings:**
   - Azure Portal → Load Balancer → Health Probes
   - Ensure probe is checking port 80, path `/health/`
   - Backend pool should point to VM

4. **Verify DNS:**
   ```bash
   nslookup dscc-shahbozms.polandcentral.cloudapp.azure.com
   ping dscc-shahbozms.polandcentral.cloudapp.azure.com
   ```

## Contact Info:
If site is still down after all checks, share the output of:
```bash
docker compose logs --tail=100 > debug.log
cat debug.log
```
