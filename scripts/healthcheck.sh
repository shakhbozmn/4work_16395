#!/bin/bash

# Health check script for 4work application

echo "Checking application health..."

# Check if Django is running
if curl -f http://localhost:8000/health > /dev/null; then
    echo "✓ Django application is healthy"
    exit 0
else
    echo "✗ Django application is not responding"
    exit 1
fi
