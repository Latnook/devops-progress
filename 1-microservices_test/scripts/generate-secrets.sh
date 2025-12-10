#!/bin/bash

# Script to generate strong secrets for the microservices environment
# This script generates cryptographically secure random secrets for:
# - API keys
# - Flask secret keys
# - Grafana admin password

echo "🔐 Security Secrets Generator"
echo "=============================="
echo ""

# Check if .env file already exists
if [ -f ".env" ]; then
    echo "⚠️  WARNING: .env file already exists!"
    read -p "Do you want to overwrite it? (y/N): " -n 1 -r
    echo
    if [[ ! $REPLY =~ ^[Yy]$ ]]; then
        echo "❌ Aborted. Existing .env file preserved."
        exit 1
    fi
fi

echo "Generating secure random secrets..."
echo ""

# Generate API key (64 characters)
API_KEY=$(openssl rand -hex 32)

# Generate dashboard secret key (64 characters)
DASHBOARD_SECRET=$(openssl rand -hex 32)

# Generate sysinfo secret key (64 characters)
SYSINFO_SECRET=$(openssl rand -hex 32)

# Generate JWT secret (64 characters)
JWT_SECRET=$(openssl rand -hex 32)

# Generate Grafana admin password (24 characters, base64)
GRAFANA_PASSWORD=$(openssl rand -base64 24)

# Create .env file
cat > .env << ENVEOF
# Security Configuration - Generated $(date)
# DO NOT commit this file to version control!

# API Keys for service-to-service authentication
# This key must be included in X-API-Key header for all API requests
API_KEY=$API_KEY

# Grafana Admin Credentials
GRAFANA_ADMIN_USER=admin
GRAFANA_ADMIN_PASSWORD=$GRAFANA_PASSWORD

# JWT Configuration
JWT_SECRET=$JWT_SECRET

# Flask Secret Keys
DASHBOARD_SECRET_KEY=$DASHBOARD_SECRET
SYSINFO_SECRET_KEY=$SYSINFO_SECRET

# Production/Development Mode
FLASK_ENV=production
NODE_ENV=production

# HTTPS Configuration (set to True when TLS is enabled)
HTTPS_ENABLED=False

# Rate Limiting Configuration
RATE_LIMIT_ENABLED=True
REDIS_URL=memory://
ENVEOF

chmod 600 .env  # Restrict permissions to owner only

echo "✅ Secrets generated successfully!"
echo ""
echo "📝 Configuration Summary:"
echo "========================"
echo "API Key: ${API_KEY:0:16}... (64 chars)"
echo "Dashboard Secret: ${DASHBOARD_SECRET:0:16}... (64 chars)"
echo "Sysinfo Secret: ${SYSINFO_SECRET:0:16}... (64 chars)"
echo "JWT Secret: ${JWT_SECRET:0:16}... (64 chars)"
echo "Grafana Password: ${GRAFANA_PASSWORD:0:8}... (32 chars)"
echo ""
echo "🔒 Security Notes:"
echo "=================="
echo "1. Secrets saved to .env file with 600 permissions"
echo "2. NEVER commit .env file to version control"
echo "3. Keep backups of .env file in a secure location"
echo "4. Rotate secrets regularly (every 90 days recommended)"
echo "5. Use environment variables or secrets management in production"
echo ""
echo "🚀 Next Steps:"
echo "=============="
echo "1. Review the generated .env file"
echo "2. Start services with: docker-compose up --build"
echo "3. Access dashboard at: http://localhost:5000"
echo "4. Access Grafana at: http://localhost:3000"
echo "   - Username: admin"
echo "   - Password: (check .env file)"
echo ""
