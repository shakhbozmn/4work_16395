.PHONY: help install test lint format clean migrate run shell docker-build docker-up docker-down docker-logs backup restore

help: ## Show this help message
	@echo 'Usage: make [target]'
	@echo ''
	@echo 'Available targets:'
	@awk 'BEGIN {FS = ":.*?## "} /^[a-zA-Z_-]+:.*?## / {printf "  %-20s %s\n", $$1, $$2}' $(MAKEFILE_LIST)

install: ## Install dependencies
	pip install -r requirements.txt
	pip install black flake8 isort pytest pytest-django pytest-cov factory-boy mypy django-stubs

test: ## Run tests with coverage
	pytest --cov=. --cov-report=html --cov-report=term

test-verbose: ## Run tests with verbose output
	pytest -vv --cov=. --cov-report=html --cov-report=term

test-fast: ## Run tests without coverage (faster)
	pytest -x

lint: ## Run linting checks
	flake8 accounts marketplace config
	isort --check-only accounts marketplace config
	black --check accounts marketplace config

format: ## Format code with black and isort
	black accounts marketplace config
	isort accounts marketplace config

check: ## Run all quality checks (lint + test)
	$(MAKE) lint
	$(MAKE) test

clean: ## Clean up temporary files
	find . -type f -name '*.pyc' -delete
	find . -type d -name '__pycache__' -delete
	find . -type d -name '*.egg-info' -exec rm -rf {} +
	rm -rf htmlcov/ .coverage .pytest_cache/

migrate: ## Run database migrations
	python manage.py makemigrations
	python manage.py migrate

makemigrations: ## Create new migrations
	python manage.py makemigrations

createsuperuser: ## Create a superuser
	python manage.py createsuperuser

collectstatic: ## Collect static files
	python manage.py collectstatic --noinput

run: ## Run development server
	python manage.py runserver

shell: ## Open Django shell
	python manage.py shell

shell-plus: ## Open Django shell with django-extensions (if installed)
	python manage.py shell_plus

load-demo-data: ## Load demo data
	python manage.py load_demo_data

docker-build: ## Build Docker images
	docker-compose build

docker-up: ## Start Docker containers
	docker-compose up -d

docker-down: ## Stop Docker containers
	docker-compose down

docker-logs: ## View Docker logs
	docker-compose logs -f

docker-restart: ## Restart Docker containers
	docker-compose restart

docker-shell: ## Open shell in Django container
	docker-compose exec web bash

docker-migrate: ## Run migrations in Docker
	docker-compose exec web python manage.py migrate

docker-collectstatic: ## Collect static files in Docker
	docker-compose exec web python manage.py collectstatic --noinput

docker-test: ## Run tests in Docker
	docker-compose exec web pytest

backup: ## Backup database
	@echo "Creating database backup..."
	docker-compose exec -T db pg_dump -U 4work_user 4work_db > backup_$(shell date +%Y%m%d_%H%M%S).sql
	@echo "Backup completed"

restore: ## Restore database from backup (usage: make restore FILE=backup.sql)
	@echo "Restoring database from $(FILE)..."
	docker-compose exec -T db psql -U 4work_user 4work_db < $(FILE)
	@echo "Restore completed"

setup: install migrate ## Complete setup (install + migrate)
	@echo "Setup complete. Run 'make run' to start the development server."

setup-dev: ## Setup development environment
	pip install pre-commit
	pre-commit install
	$(MAKE) setup

deploy: ## Deploy to production (requires SSH access)
	@echo "Deploying to production..."
	./scripts/deploy.sh

healthcheck: ## Check application health
	./scripts/healthcheck.sh

install-deps: ## Install all dependencies including dev tools
	pip install -r requirements.txt
	pip install black==24.3.0 flake8==7.0.0 isort==5.13.2
	pip install pytest==8.1.1 pytest-django==4.8.0 pytest-cov==4.1.0
	pip install factory-boy==3.3.0 mypy==1.9.0 django-stubs==4.2.7
