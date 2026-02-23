# 4work - Freelance Marketplace Platform
**Note:** This project was created as an assignment for the DSCC course and is for educational purposes only. It does not represent or belong to any real application, company, or commercial entity.

## Project Description

4work is a web-based platform that allows:
- **Clients** to create and manage projects with budgets and deadlines
- **Freelancers** to browse projects and submit applications
- **Project owners** to review applications and assign projects to freelancers

The platform features user authentication, project categorization, skill-based profiles, and a clean, intuitive interface designed for ease of use.

## Features List

### User Management
- User registration with role selection (Client/Freelancer)
- Secure login and logout functionality
- User profiles with bio, hourly rate, and skills
- Avatar upload support

### Project Management
- Create projects with title, description, budget, deadline, and category
- Browse all open projects with search and category filtering
- View project details and applications
- Edit and delete own projects
- Assign freelancers to projects

### Application System
- Freelancers can apply to open projects
- Submit cover letter, proposed timeline, and budget
- Clients can accept or reject applications
- Automatic status updates (Pending, Accepted, Rejected)

### Categories
- Pre-defined project categories
- Filter projects by category
- Category detail pages showing related projects

### Skills
- Freelancers can add skills to their profiles
- Skills help clients find suitable freelancers

## Technologies Used

### Backend
- **Django 6.** - Python web framework
- **PostgreSQL** - Relational database

### Frontend
- **HTML5/Tailwind** - Markup and styling
- **JavaScript** - Client-side interactivity
- **Bootstrap 5** - Responsive UI framework (via CDN)

### Deployment
- **Docker** - Containerization
- **Docker Compose** - Multi-container orchestration
- **Nginx** - Reverse proxy and static file serving
- **Gunicorn** - Python WSGI HTTP Server

### Development Tools
- **Python 3.12+** - Programming language
- **pytest** - Testing framework
- **flake8** - Code linting
- **isort** - Import sorting

## Local Setup Instructions

### Prerequisites
- Python 3.11 or higher
- PostgreSQL 14 or higher
- pip (Python package manager)
- Git

### Installation Steps

1. **Clone the repository**
   ```bash
   git clone https://github.com/shakhbozmn/4work_16395.git
   cd 4work_16395
   ```

2. **Create a virtual environment**
   ```bash
   python -m venv venv
   source venv/bin/activate  # On Windows: venv\Scripts\activate
   ```

3. **Install dependencies**
   ```bash
   pip install -r requirements.txt
   ```

4. **Configure environment variables**
   Copy the example environment file and edit it:
   ```bash
   cp .env.example .env
   ```

   Edit `.env` with your settings:
   ```env
   DEBUG=True
   SECRET_KEY=your-secret-key-here
   DB_NAME=4work_db
   DB_USER=4work_user
   DB_PASSWORD=your-db-password
   DB_HOST=localhost
   DB_PORT=5432
   ```

5. **Set up PostgreSQL database**
   ```bash
   # Create database
   createdb 4work_db

   # Create user (if needed)
   createuser 4work_user
   ```

6. **Run database migrations**
   ```bash
   python manage.py migrate
   ```

7. **Create a superuser (optional)**
   ```bash
   python manage.py createsuperuser
   ```

8. **Load demo data (optional)**
   ```bash
   python manage.py load_demo_data
   ```

9. **Run the development server**
   ```bash
   python manage.py runserver
   ```

10. **Access the application**
    Open your browser and navigate to: `http://localhost:8000`

### Running Tests

Run all tests:
```bash
python manage.py test
```

Run tests for a specific app:
```bash
python manage.py test accounts
python manage.py test marketplace
```

Run with verbose output:
```bash
python manage.py test --verbosity=2
```

### Azure VM Deployment

**Server Details:**
- **DNS**: `dscc-shahbozms.polandcentral.cloudapp.azure.com`
- **Platform**: Docker + Nginx + Gunicorn
- **Database**: PostgreSQL (Docker container)
- **SSL**: Let's Encrypt certificates

### Prerequisites
- SSH access to the Azure VM
- Docker and Docker Compose installed on the VM
- PostgreSQL running in Docker container
- Let's Encrypt SSL certificates configured

### Deployment Steps

1. **SSH into the server**
   ```bash
   ssh user@dscc-shahbozms.polandcentral.cloudapp.azure.com
   ```

2. **Clone the repository**
   ```bash
   cd /opt
   git clone [<repository-url>](https://github.com/shakhbozmn/4work_16395.git) 4work
   cd 4work
   ```

3. **Configure environment variables**
   ```bash
   cp .env.example .env.production
   nano .env.production
   ```

   Set production values:
   ```env
   DEBUG=False
   SECRET_KEY=your-production-secret-key
   DB_NAME=4work_db
   DB_USER=4work_user
   DB_PASSWORD=your-production-db-password
   DB_HOST=db  # Docker service name
   DB_PORT=5432
   ALLOWED_HOSTS=dscc-shahbozms.polandcentral.cloudapp.azure.com
   SITE_URL=https://dscc-shahbozms.polandcentral.cloudapp.azure.com
   ```

4. **Build and run Docker containers**
   ```bash
   docker-compose -f docker-compose.yml --env-file .env.production up -d --build
   ```

5. **Run database migrations**
   ```bash
   docker-compose exec web python manage.py migrate
   ```

6. **Create superuser (if needed)**
   ```bash
   docker-compose exec web python manage.py createsuperuser
   ```

7. **Collect static files**
   ```bash
   docker-compose exec web python manage.py collectstatic --noinput
   ```

8. **Verify deployment**
   - Check container status: `docker-compose ps`
   - View logs: `docker-compose logs -f`
   - Access: `https://dscc-shahbozms.polandcentral.cloudapp.azure.com`

### Docker Services

The `docker-compose.yml` file defines the following services:

- **web**: Django application with Gunicorn
- **db**: PostgreSQL database
- **nginx**: Reverse proxy and static file server

### Nginx Configuration

Nginx is configured with:
- SSL/TLS support using Let's Encrypt certificates
- Proxy to Gunicorn for Django application
- Static file serving
- Security headers

SSL certificate paths:
- Certificate: `/etc/letsencrypt/live/dscc-shahbozms.polandcentral.cloudapp.azure.com/fullchain.pem`
- Private Key: `/etc/letsencrypt/live/dscc-shahbozms.polandcentral.cloudapp.azure.com/privkey.pem`

### Common Deployment Commands

View logs:
```bash
docker-compose logs -f web
```

Restart services:
```bash
docker-compose restart
```

Stop all services:
```bash
docker-compose down
```

Update the application:
```bash
git pull
docker-compose up -d --build
docker-compose exec web python manage.py migrate
docker-compose exec web python manage.py collectstatic --noinput
```

## Environment Variables Documentation

| Variable | Description | Default | Required |
|----------|-------------|---------|----------|
| `DEBUG` | Enable debug mode (True/False) | `True` | No |
| `SECRET_KEY` | Django secret key for cryptographic signing | - | Yes |
| `DB_NAME` | PostgreSQL database name | `4work_db` | Yes |
| `DB_USER` | PostgreSQL username | `4work_user` | Yes |
| `DB_PASSWORD` | PostgreSQL password | - | Yes |
| `DB_HOST` | PostgreSQL host address | `localhost` | Yes |
| `DB_PORT` | PostgreSQL port | `5432` | No |
| `ALLOWED_HOSTS` | Comma-separated list of allowed hosts | `localhost` | Yes (production) |
| `SITE_NAME` | Site name | `4work` | No |
| `SITE_URL` | Site URL | `http://localhost:8000` | No |
| `EMAIL_HOST` | SMTP server host | `smtp.gmail.com` | No |
| `EMAIL_PORT` | SMTP server port | `587` | No |
| `EMAIL_HOST_USER` | SMTP username | - | No |
| `EMAIL_HOST_PASSWORD` | SMTP password | - | No |
| `CORS_ALLOWED_ORIGINS` | Comma-separated CORS origins | - | No |
| `CSRF_TRUSTED_ORIGINS` | Comma-separated CSRF origins | - | No |

### Development vs Production

**Development:**
- `DEBUG=True`
- `ALLOWED_HOSTS=localhost,127.0.0.1`
- Email backend: Console (no emails sent)
- Cache: Local memory cache

**Production:**
- `DEBUG=False`
- `ALLOWED_HOSTS=your-domain.com`
- Email backend: SMTP (if configured)
- Security settings enabled (HTTPS, secure cookies, HSTS)

## Project Structure

```
4work_16395/
├── accounts/              # User authentication and profiles
│   ├── models.py         # User, Profile, Skill models
│   ├── views.py          # Authentication and profile views
│   ├── forms.py          # User and profile forms
│   └── tests/           # Account tests
├── marketplace/          # Projects and applications
│   ├── models.py         # Project, Category, Application models
│   ├── views.py          # Project and application views
│   ├── forms.py          # Project and application forms
│   └── tests/           # Marketplace tests
├── config/               # Django configuration
│   ├── settings.py       # Main settings file
│   ├── urls.py          # Root URL configuration
│   └── wsgi.py         # WSGI configuration
├── templates/            # HTML templates
│   ├── accounts/        # Account-related templates
│   ├── marketplace/     # Marketplace-related templates
│   └── components/     # Reusable components
├── static/              # Static files (CSS, JS, images)
├── media/               # User-uploaded files
├── docker-compose.yml    # Docker Compose configuration
├── Dockerfile           # Docker image configuration
├── requirements.txt     # Python dependencies
└── README.md           # This file
```

