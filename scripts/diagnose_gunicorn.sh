#!/bin/bash
# Diagnostic script to check gunicorn configuration

echo "=== Gunicorn Diagnostic Check ==="
echo ""

echo "1. Checking gunicorn version:"
gunicorn --version
echo ""

echo "2. Checking entrypoint script content:"
cat /app/bin/entrypoint.sh
echo ""

echo "3. Checking Docker image build info (if available):"
cat /etc/os-release 2>/dev/null || echo "OS release info not available"
echo ""

echo "4. Checking gunicorn help to see available arguments:"
gunicorn --help | grep -i preload || echo "No preload-related arguments found"
echo ""

echo "5. Checking if there are any override files:"
ls -la /app/bin/ 2>/dev/null || echo "No bin directory"
echo ""

echo "6. Checking environment variables related to gunicorn:"
env | grep -i gunicorn || echo "No gunicorn-related environment variables"
echo ""

echo "=== End of Diagnostic Check ==="
