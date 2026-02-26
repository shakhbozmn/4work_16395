# 4work – Freelance Marketplace Platform
> **Note:** This project was made as part of DSCC module assigment and does not represent any real company or industry.

---

## 1. Project Description

4work is a small-scale freelance marketplace built with Django. It helps two groups:
- **Clients** publish project briefs, review incoming bids, and assign accepted freelancers.
- **Freelancers** maintain skill-based profiles, browse active projects, and submit detailed applications.

---

## 2. Features List

| Area | Highlights |
|------|------------|
| **Authentication & Profiles** | Custom `User` model, registration with role selection (Client/Freelancer), login/logout, profile editing with hourly rate, bio, avatar uploads, and many-to-many skills. |
| **Project Management** | CRUD interface for projects with budget, deadline, and category fields, plus list/search/filter pages so freelancers can discover work. |
| **Application Workflow** | Freelancers submit cover letters and proposed terms; clients accept or reject applications with automatic status updates. |
| **Dashboards** | Separate landing pages for freelancers (applications + recommended projects) and clients (their projects + applicants). |
| **Content Structure** | Categories, skills, pagination, reusable template components, and a responsive layout.

---

## 3. Screenshots (Live Azure Deployment)

All screenshots are captured directly from `https://dscc-shahbozms.polandcentral.cloudapp.azure.com`, so anyone grading the project can see the real site.

![Home Page](https://image.thum.io/get/width/1200/crop/720/https://dscc-shahbozms.polandcentral.cloudapp.azure.com/)
![Project Listings](https://image.thum.io/get/width/1200/crop/720/https://dscc-shahbozms.polandcentral.cloudapp.azure.com/marketplace/projects/)
![Freelancer Dashboard](https://image.thum.io/get/width/1200/crop/720/https://dscc-shahbozms.polandcentral.cloudapp.azure.com/dashboard/freelancer/)

---

## 4. Technologies Used

| Layer | Tools |
|-------|-------|
| Backend | Django 6, Django ORM, Gunicorn WSGI server |
| Database | PostgreSQL 15 (Dockerized) |
| Frontend | HTML5, Tailwind utility classes, Bootstrap 5 for quick layout help, vanilla JavaScript |
| Dev Tooling | Python 3.12, pip, pytest, flake8, isort, black, pre-commit hooks |
| Infrastructure | Docker & Docker Compose, Azure VM, Nginx reverse proxy, Let’s Encrypt SSL |

---

## 5. Local Setup Instructions (Step-by-Step)

### 5.1 Prerequisites
- Python 3.12+
- PostgreSQL 14+
- Git
- Recommended: `make` (for shortcuts) and Docker Desktop if you want to match the production stack.

### 5.2 Installation Steps
1. **Clone repo & create virtualenv**
   ```bash
   git clone https://github.com/shakhbozmn/4work_16395.git
   cd 4work_16395
   python -m venv venv
   source venv/bin/activate  # Windows: venv\Scripts\activate
   ```
2. **Install dependencies**
   ```bash
   pip install --upgrade pip
   pip install -r requirements.txt
   ```
3. **Configure `.env`**
   ```bash
   cp .env.example .env
   nano .env  # or any editor
   ```
   Fill in at least the database credentials and `SECRET_KEY` (see the Environment Variables table below).
4. **Prepare PostgreSQL**
   ```bash
   createdb 4work_db
   createuser 4work_user --pwprompt
   ```
5. **Run database migrations & optional demo data**
   ```bash
   python manage.py migrate
   python manage.py load_demo_data  # optional seed content
   ```
6. **Create superuser (optional but useful for grading)**
   ```bash
   python manage.py createsuperuser
   ```
7. **Start the dev server**
   ```bash
   python manage.py runserver
   ```
8. **Visit** `http://localhost:8000` and sign in with the credentials you created.

### 5.3 Running the Test Suite
```bash
pytest            # 59 tests across accounts + marketplace apps
pytest accounts   # focus on one app
pytest -vv        # verbose output with timings
```

---

## 6. Environment Variables Documentation

| Variable | Purpose | Example | Required? |
|----------|---------|---------|-----------|
| `DEBUG` | Enables Django debug pages locally | `True` | Dev only |
| `SECRET_KEY` | Cryptographic signing key | `django-insecure-...` | **Yes** |
| `DB_NAME` | PostgreSQL database name | `4work_db` | **Yes** |
| `DB_USER` | Database username | `4work_user` | **Yes** |
| `DB_PASSWORD` | Database password | `super-secret` | **Yes** |
| `DB_HOST` | Database host or service name | `localhost` / `db` | **Yes** |
| `DB_PORT` | Database port | `5432` | No |
| `ALLOWED_HOSTS` | Comma-separated list of domains | `localhost,127.0.0.1` | Required in prod |
| `SITE_URL` | Public site URL | `https://dscc...azure.com` | Prod only |
| `EMAIL_*` vars | Optional SMTP settings | Gmail SMTP | Optional |
| `CORS_ALLOWED_ORIGINS` | If a JS frontend is added later | `https://example.com` | Optional |
| `CSRF_TRUSTED_ORIGINS` | Required when using HTTPS domains | `https://dscc...azure.com` | Prod only |

**Tip for classmates:** copy `.env.example`, fill only what you need, and keep both `.env` and `.env.production` out of Git (already covered in `.gitignore`).

---

## 7. Deployment Instructions (Azure VM + Docker)

### 7.1 Topology
- **Host:** Azure VM (Ubuntu LTS) with Docker + Docker Compose
- **Containers:** `db` (Postgres), `web` (Django + Gunicorn), `nginx` (reverse proxy + SSL)
- **CI/CD:** GitHub Actions builds the Docker image, pushes to Docker Hub, then runs `deploy.sh` over SSH for zero-downtime restarts.

### 7.2 One-Time Server Setup
```bash
ssh azure-user@dscc-shahbozms.polandcentral.cloudapp.azure.com
sudo apt update && sudo apt install docker.io docker-compose-plugin
sudo mkdir -p /opt/4work && cd /opt/4work
git clone https://github.com/shakhbozmn/4work_16395.git .
cp .env.example .env.production
# edit .env.production with production credentials + domains
docker compose up -d db  # optional: warm up database first
```

### 7.3 Continuous Deployment Flow
1. Push to the `main` branch → GitHub Actions runs linting & tests.
2. On success, the workflow builds the Docker image, tags it as `latest` and `commit-sha`, and pushes to Docker Hub.
3. The `deploy` job SSHs into the Azure VM and runs `deploy.sh`, which:
   - pulls the latest code (`git pull origin main`)
   - pulls the pre-built Docker image (`docker compose pull web`)
   - restarts only the `web` service (`up -d --no-deps --force-recreate web`) so PostgreSQL + Nginx stay online
   - runs `manage.py migrate` and `collectstatic`
   - prints container status + recent logs for quick validation

### 7.4 Manual Deployment Commands (in my case ci_cd_fix branch were used for manual deployment)
1. `deploy.sh` file were configured for triggering deployment script, for direct and all-in-one script
2. Navigate to `/opt/4work`, and run `deploy.sh` script
3. Example content of `deploy.sh`:

### 7.5 Useful Operational Commands
```bash
docker compose ps                     
docker compose logs -f web            
docker compose restart nginx          
docker compose down                   
```

---

## 8. Project Structure

```
4work_16395/
├── accounts/          # Custom user model, profiles, forms, signals, tests
├── marketplace/       # Projects, applications, categories, tests
├── config/            # Django settings split (development, production, test)
├── templates/         # Base layout + auth, dashboard, marketplace UIs
├── static/            # Local static assets (collected into /staticfiles in prod)
├── media/             # Uploaded avatars (mounted as a Docker volume)
├── docker-compose*.yml# Production + developer compose files
├── entrypoint.sh      # Container bootstrap: wait for DB, migrate, collectstatic
├── deploy.sh          # Zero-downtime deployment script used by GitHub Actions
├── requirements.txt   # Python dependencies
└── README.md          # This guide
```

---

