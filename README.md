# 4work - Freelance Job Marketplace

A modern, minimalistic freelance job marketplace built with Django, featuring user authentication, project management, and application tracking.

## Features

- **User Authentication**: Custom user model with role-based access (Client/Freelancer)
- **Project Management**: Full CRUD operations for job postings
- **Application System**: Freelancers can apply to projects with cover letters
- **Profile Management**: Users can manage their profiles, skills, and hourly rates
- **Category System**: Browse projects by category
- **Search & Filtering**: Advanced search with category and status filters
- **Responsive Design**: Modern UI built with Tailwind CSS
- **Admin Panel**: Full admin interface for managing all data
- **Docker Support**: Multi-container setup with PostgreSQL, Nginx, and Redis
- **Production Ready**: Security hardening, SSL support, and optimized configuration

## Technologies Used

### Backend
- **Django 5.2.10** - Web framework
- **Python 3.11+** - Programming language
- **PostgreSQL 15+** - Primary database
- **Gunicorn 21+** - WSGI server
- **Redis 7+** - Caching and sessions
- **python-dotenv** - Environment variable management
- **django-cors-headers** - CORS handling

### Frontend
- **Tailwind CSS 3.x** - Utility-first CSS framework
- **HTML5** - Markup
- **Vanilla JavaScript** - Minimal dependencies

### DevOps
- **Docker 24+** - Containerization
- **Docker Compose 2.x** - Multi-container orchestration
- **Nginx 1.25+** - Reverse proxy and static file serving
- **GitHub Actions** - CI/CD pipeline

### Development Tools
- **pytest-django** - Testing framework
- **black** - Code formatter
- **flake8** - Linter
- **isort** - Import sorter
- **factory_boy** - Test data generation

## Database Schema

### Models (6 total)
1. **User** - Custom user model with role (client/freelancer)
2. **Skill** - Freelancer skills catalog
3. **Profile** - User profiles with bio, hourly rate, skills (M2M)
4. **Category** - Project categories
5. **Project** - Job postings with budget, status, assignments
6. **Application** - Freelancer applications to projects

### Relationships
- User ↔ Profile (One-to-One)
- Profile ↔ Skill (Many-to-Many)
- User → Projects as client (Many-to-One)
- User → Projects as freelancer (Many-to-One)
- Category → Projects (Many-to-One)
- Project → Applications (Many-to-One)
- User → Applications (Many-to-One)

## Pages/Views (12+)

1. **Home** (`/`) - Landing page with statistics
2. **Project List** (`/projects/`) - Browse all projects with filters
3. **Project Detail** (`/projects/<id>/`) - View project and applications
4. **Create Project** (`/projects/create/`) - Post new project (clients only)
5. **Update Project** (`/projects/<id>/update/`) - Edit project (owner only)
6. **Delete Project** (`/projects/<id>/delete/`) - Delete project (owner only)
7. **Apply to Project** (`/projects/<id>/apply/`) - Submit application (freelancers only)
8. **Category List** (`/categories/`) - Browse all categories
9. **Category Detail** (`/categories/<id>/`) - View projects by category
10. **Profile Detail** (`/profile/<username>/`) - View user profile
11. **Edit Profile** (`/profile/edit/`) - Update own profile
12. **Login** (`/login/`) - User authentication
13. **Register** (`/register/`) - New user registration
14. **Logout** (`/logout/`) - User logout

## Installation

### Prerequisites

- Python 3.11+
- Docker 24+
- Docker Compose 2.x+
- PostgreSQL 15+ (or use Docker)

### Local Setup

1. Clone the repository:
```bash
git clone https://github.com/yourusername/4work.git
cd 4work
```

2. Create a virtual environment:
```bash
python -m venv venv
source venv/bin/activate  # On Windows: venv\Scripts\activate
```

3. Install dependencies:
```bash
pip install -r requirements.txt
```

4. Copy environment variables:
```bash
cp .env.example .env
```

5. Edit `.env` file with your configuration:
```bash
DEBUG=True
SECRET_KEY=your-secret-key-here
ALLOWED_HOSTS=localhost,127.0.0.1
DB_NAME=4work_dev_db
DB_USER=4work_dev_user
DB_PASSWORD=your-db-password
DB_HOST=localhost
DB_PORT=5432
REDIS_HOST=localhost
REDIS_PORT=6379
REDIS_DB=0
```

6. Run database migrations:
```bash
python manage.py migrate
```

7. Load demo data (optional):
```bash
python manage.py load_demo_data
```

8. Create a superuser:
```bash
python manage.py createsuperuser
```

9. Run the development server:
```bash
python manage.py runserver
```

10. Access the application:
- Open your browser and navigate to `http://localhost:8000`
- Login with the demo credentials:
  - Client: `john_client` / `password123`
  - Freelancer: `jane_freelancer` / `password123`
  - Freelancer: `bob_freelancer` / `password123`

### Docker Setup

1. Build and start all services:
```bash
docker-compose up -d
```

2. View logs:
```bash
docker-compose logs -f
```

3. Stop services:
```bash
docker-compose down
```

4. Rebuild services:
```bash
docker-compose up -d --build
```

## Environment Variables

| Variable | Description | Default | Required |
|----------|-------------|---------|----------|
| `SECRET_KEY` | Django secret key | Yes |
| `DEBUG` | Debug mode (True/False) | Yes |
| `ALLOWED_HOSTS` | Comma-separated hosts | Yes |
| `DB_NAME` | Database name | Yes |
| `DB_USER` | Database user | Yes |
| `DB_PASSWORD` | Database password | Yes |
| `DB_HOST` | Database host | Yes |
| `DB_PORT` | Database port | Yes |
| `REDIS_HOST` | Redis host | Yes |
| `REDIS_PORT` | Redis port | Yes |
| `REDIS_DB` | Redis database | Yes |
| `EMAIL_HOST` | SMTP host | No |
| `EMAIL_PORT` | SMTP port | No |
| `EMAIL_USE_TLS` | Use TLS | No |
| `EMAIL_HOST_USER` | SMTP username | No |
| `EMAIL_HOST_PASSWORD` | SMTP password | No |
| `SITE_NAME` | Site name | Yes |
| `SITE_URL` | Site URL | Yes |
| `CORS_ALLOWED_ORIGINS` | CORS origins | Yes |
| `CSRF_TRUSTED_ORIGINS` | CSRF origins | Yes |

## Docker Services

### Services

1. **django** - Django application with Gunicorn
2. **postgres** - PostgreSQL database
3. **redis** - Redis cache
4. **nginx** - Reverse proxy and static file serving

### Volumes

- `postgres_data` - PostgreSQL data persistence
- `redis_data` - Redis data persistence
- `static_volume` - Static files
- `media_volume` - Media files

### Networking

- `4work_network` - Custom bridge network for inter-service communication

## Admin Panel

Access the admin panel at `/admin/` with your superuser credentials.

## Deployment

### Prerequisites

- Docker and Docker Compose installed on server
- Domain DNS configured to point to server IP
- SSH access to server

### Deployment Steps

1. Copy `.env.production` to server:
```bash
scp .env.production user@your-server-ip:/path/to/4work/
```

2. SSH into the server:
```bash
ssh user@your-server-ip
```

3. Navigate to project directory:
```bash
cd /path/to/4work
```

4. Create production `.env` file:
```bash
cp .env.production .env
```

5. Edit `.env` with production values:
```bash
DEBUG=False
SECRET_KEY=your-production-secret-key
ALLOWED_HOSTS=yourdomain.uz,www.yourdomain.uz
DB_NAME=4work_prod_db
DB_USER=4work_prod_user
DB_PASSWORD=your-secure-db-password
DB_HOST=postgres
DB_PORT=5432
REDIS_HOST=redis
REDIS_PORT=6379
REDIS_DB=0
```

6. Start services:
```bash
docker-compose up -d
```

7. Run database migrations:
```bash
docker-compose exec django python manage.py migrate
```

8. Collect static files:
```bash
docker-compose exec django python manage.py collectstatic --noinput
```

9. Load demo data (optional):
```bash
docker-compose exec django python manage.py load_demo_data
```

### SSL Certificate Setup

1. Install Certbot:
```bash
sudo apt-get update
sudo apt-get install -y certbot python3-certbot-nginx
```

2. Obtain SSL certificate:
```bash
sudo certbot --nginx -d yourdomain.uz
```

3. Copy certificates to nginx directory:
```bash
sudo cp /etc/letsencrypt/live/yourdomain.uz/fullchain.pem /path/to/4work/nginx/ssl/
sudo cp /etc/letsencrypt/live/yourdomain.uz/privkey.pem /path/to/4work/nginx/ssl/
```

4. Restart Nginx:
```bash
docker-compose restart nginx
```

## Testing

### Run Tests

```bash
pytest
```

### Run Tests with Coverage

```bash
pytest --cov=. --cov-report=html
```

### Load Demo Data

```bash
python manage.py load_demo_data
```

## Project Structure

```
4work_16395/
├── .github/
│   └── workflows/
│       └── deploy.yml
├── accounts/
│   ├── management/
│   │   └── commands/
│   │       └── load_demo_data.py
│   ├── migrations/
│   ├── __init__.py
│   ├── admin.py
│   ├── apps.py
│   ├── forms.py
│   ├── models.py
│   ├── tests/
│   ├── urls.py
│   └── views.py
├── config/
│   ├── settings/
│   │   ├── __init__.py
│   │   ├── base.py (will be created)
│   │   ├── development.py (will be created)
│   │   └── production.py
│   ├── __init__.py
│   ├── asgi.py
│   ├── gunicorn.py
│   ├── settings.py
│   ├── urls.py
│   └── wsgi.py
├── fixtures/
│   ├── categories.json
│   ├── demo_data.json
│   └── skills.json
├── marketplace/
│   ├── migrations/
│   ├── __init__.py
│   ├── admin.py
│   ├── apps.py
│   ├── forms.py
│   ├── models.py
│   ├── tests/
│   ├── urls.py
│   └── views.py
├── nginx/
│   ├── Dockerfile
│   ├── nginx.conf
│   └── ssl/
├── scripts/
│   ├── deploy.sh
│   ├── healthcheck.sh
│   └── setup_ssl.sh
├── static/
│   ├── css/
│   ├── js/
│   └── images/
├── templates/
│   ├── accounts/
│   ├── auth/
│   ├── components/
│   ├── dashboard/
│   ├── errors/
│   ├── marketplace/
│   ├── base.html
│   └── home.html
├── .dockerignore
├── .env.example
├── .env.development
├── Dockerfile
├── docker-compose.yml
├── docker-compose.dev.yml
├── manage.py
├── pytest.ini
├── requirements.txt
└── README.md
```

## Screenshots

*Note: Screenshots will be added after deployment*

### Home Page
- Modern hero section with call-to-action buttons
- Statistics display (500+ projects, 1000+ freelancers, 50+ categories)

### Project List
- Grid layout with project cards
- Category badges
- Status indicators
- Budget display
- Pagination

### Project Detail
- Full project information
- Application list
- Apply button (freelancers only)
- Accept/Reject buttons (project owner only)

### Profile Pages
- User profile with avatar
- Skills display
- Hourly rate
- Statistics (projects posted, applications made)

### Dashboard
- Role-based dashboard (client/freelancer)
- Quick stats
- Recent activity

## Contributing

1. Fork the repository
2. Create a feature branch (`git checkout -b feature/amazing-feature`)
3. Make your changes
4. Commit your changes (`git commit -m 'Add amazing feature'`)
5. Push to the branch (`git push origin feature/amazing-feature`)
6. Open a Pull Request

## License

This project is licensed under the MIT License.

## Author

Built for DSCC Course Project - 4work Freelance Job Marketplace
