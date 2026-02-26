# syntax=docker/dockerfile:1

# Stage 1: Builder - compile dependencies
FROM python:3.12-slim AS builder

ARG DEBIAN_FRONTEND=noninteractive

ENV PYTHONDONTWRITEBYTECODE=1
ENV PYTHONUNBUFFERED=1

WORKDIR /app

# Build dependencies only (gcc needed to compile psycopg2 and other C extensions)
RUN --mount=type=cache,target=/var/cache/apt,sharing=locked \
    --mount=type=cache,target=/var/lib/apt,sharing=locked \
    apt-get update && apt-get install -y --no-install-recommends \
    gcc \
    libpq-dev

COPY requirements.txt .

RUN --mount=type=cache,target=/root/.cache/pip \
    pip install --upgrade pip && \
    pip install -r requirements.txt

# Stage 2: Production - lean runtime image
FROM python:3.12-slim

ARG DEBIAN_FRONTEND=noninteractive

ENV PYTHONDONTWRITEBYTECODE=1
ENV PYTHONUNBUFFERED=1

# Create non-root user
RUN groupadd -r appuser && useradd -r -g appuser appuser

WORKDIR /app

# Runtime dependencies only (no gcc)
RUN --mount=type=cache,target=/var/cache/apt,sharing=locked \
    --mount=type=cache,target=/var/lib/apt,sharing=locked \
    apt-get update && apt-get install -y --no-install-recommends \
    libpq-dev \
    postgresql-client \
    curl \
    netcat-openbsd \
    gosu

# Copy compiled Python packages and binaries from builder
COPY --from=builder /usr/local/lib/python3.12/site-packages /usr/local/lib/python3.12/site-packages
COPY --from=builder /usr/local/bin/gunicorn /usr/local/bin/gunicorn

# Copy application code
COPY --chown=appuser:appuser . .

# Ensure entrypoint is executable after copy
RUN chmod +x /app/entrypoint.sh

# Create static and media dirs
RUN mkdir -p /app/staticfiles /app/media && \
    chown -R appuser:appuser /app/staticfiles /app/media

EXPOSE 8000

HEALTHCHECK --interval=30s --timeout=10s --start-period=30s --retries=3 \
    CMD curl -f http://localhost:8000/health/ || exit 1

ENTRYPOINT ["/app/entrypoint.sh"]
