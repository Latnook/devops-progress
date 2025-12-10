# Security Guide

This document describes the security features and best practices implemented in the microservices architecture.

## Table of Contents

1. [Security Overview](#security-overview)
2. [Quick Start - Secure Setup](#quick-start---secure-setup)
3. [Security Features](#security-features)
4. [Authentication & Authorization](#authentication--authorization)
5. [Secrets Management](#secrets-management)
6. [Container Security](#container-security)
7. [Network Security](#network-security)
8. [Security Monitoring](#security-monitoring)
9. [Production Deployment](#production-deployment)
10. [Security Checklist](#security-checklist)

## Security Overview

This microservices architecture implements OWASP Top 10 best practices and includes comprehensive security controls across all layers:

- **A01 - Broken Access Control**: API key authentication on all endpoints
- **A02 - Cryptographic Failures**: Secrets management, secure session configuration
- **A03 - Injection**: Input validation, output sanitization, XSS protection
- **A04 - Insecure Design**: Rate limiting, circuit breakers, secure defaults
- **A05 - Security Misconfiguration**: Non-root containers, production servers, security headers
- **A06 - Vulnerable Components**: Dependency tracking, version pinning
- **A07 - Authentication Failures**: API key auth, strong passwords, session timeouts
- **A08 - Software Integrity**: Dependency verification (planned)
- **A09 - Logging Failures**: Security event logging, audit trails
- **A10 - SSRF**: URL validation, request filtering

##Quick Start - Secure Setup

### 1. Generate Secrets

```bash
cd scripts
./generate-secrets.sh
```

This creates a `.env` file with:
- Strong API keys (256-bit)
- Flask secret keys for session signing
- Secure Grafana admin password
- JWT secrets for token signing

### 2. Review Configuration

```bash
cat .env  # Review generated secrets
```

**IMPORTANT**: Never commit `.env` file to version control!

### 3. Start Services

```bash
docker-compose up --build
```

### 4. Test Authentication

```bash
# Without API key (should fail with 401)
curl http://localhost:5001/api/time

# With API key from .env file (should succeed)
API_KEY=$(grep "^API_KEY=" .env | cut -d= -f2)
curl -H "X-API-Key: $API_KEY" http://localhost:5001/api/time
```

## Security Features

### Implemented Security Controls

#### 1. Authentication & Authorization
- ✅ API key authentication on all service endpoints
- ✅ Authentication middleware in all services
- ✅ Failed authentication logging and metrics
- ✅ Secure credential storage via environment variables

#### 2. Input Validation & Sanitization
- ✅ Output encoding to prevent XSS attacks
- ✅ Hostname sanitization in system-info service
- ✅ URL validation to prevent SSRF
- ✅ HTML escaping of all user-controlled data

#### 3. Security Headers
- ✅ X-Content-Type-Options: nosniff
- ✅ X-Frame-Options: DENY
- ✅ X-XSS-Protection: 1; mode=block
- ✅ Referrer-Policy: strict-origin-when-cross-origin
- ✅ Content-Security-Policy configured
- ✅ Strict-Transport-Security (when HTTPS enabled)

#### 4. Container Security
- ✅ Non-root users in all containers
- ✅ Resource limits (CPU/Memory)
- ✅ Read-only root filesystem support
- ✅ Health checks with proper timeouts
- ✅ Image version pinning

#### 5. Network Security
- ✅ Services bound to localhost by default
- ✅ Network segmentation via Docker networks
- ✅ Prometheus/Grafana not exposed externally
- ✅ Internal service communication only

#### 6. Production Readiness
- ✅ Gunicorn production server for Python services
- ✅ NODE_ENV=production for Node.js
- ✅ Debug mode explicitly disabled
- ✅ Graceful shutdown handling
- ✅ Proper error handling without information leakage

#### 7. Security Logging
- ✅ Authentication failure logging
- ✅ Separate security logger
- ✅ Request/response logging
- ✅ Prometheus metrics for security events

## Authentication & Authorization

### API Key Authentication

All service endpoints (except `/health` and `/metrics`) require API key authentication.

#### How It Works

1. Client includes API key in `X-API-Key` header
2. Service validates key against configured `API_KEY` environment variable
3. If valid, request proceeds; otherwise returns 401 Unauthorized

#### Example Requests

**Dashboard Service:**
```bash
# Aggregated data (requires auth)
curl -H "X-API-Key: your-api-key-here" \
  http://localhost:5000/api/aggregate
```

**Time Service:**
```bash
# Get current time (requires auth)
curl -H "X-API-Key: your-api-key-here" \
  http://localhost:5001/api/time
```

**System Info Service:**
```bash
# Get system info (requires auth)
curl -H "X-API-Key: your-api-key-here" \
  http://localhost:5002/api/sysinfo
```

**Weather Service:**
```bash
# Get weather data (requires auth)
curl -H "X-API-Key: your-api-key-here" \
  http://localhost:5003/api/weather
```

### Public Endpoints (No Auth Required)

These endpoints are publicly accessible:
- `/health` - Health check for monitoring
- `/metrics` - Prometheus metrics scraping

### Failed Authentication Handling

Failed authentication attempts are:
1. Logged with client IP and endpoint
2. Tracked in Prometheus metrics (`*_auth_failures_total`)
3. Returned with generic error message (no details leaked)

## Secrets Management

### Environment Variables

Secrets are managed through environment variables:

```bash
# Service authentication
API_KEY=your-256-bit-api-key

# Flask session encryption
DASHBOARD_SECRET_KEY=your-secret-key
SYSINFO_SECRET_KEY=your-secret-key

# JWT token signing
JWT_SECRET=your-jwt-secret

# Grafana admin access
GRAFANA_ADMIN_USER=admin
GRAFANA_ADMIN_PASSWORD=your-strong-password
```

### Secret Generation

Use the provided script:
```bash
./scripts/generate-secrets.sh
```

### Secret Rotation

To rotate secrets:

1. Generate new secrets:
   ```bash
   mv .env .env.backup
   ./scripts/generate-secrets.sh
   ```

2. Restart services:
   ```bash
   docker-compose down
   docker-compose up -d
   ```

3. Update all clients with new API key

### Production Secrets Management

For production, use:
- **AWS**: AWS Secrets Manager or Parameter Store
- **Azure**: Azure Key Vault
- **GCP**: Google Cloud Secret Manager  
- **Kubernetes**: Kubernetes Secrets
- **Vault**: HashiCorp Vault

Example with Docker Secrets:
```yaml
secrets:
  api_key:
    file: ./secrets/api_key.txt

services:
  time-service:
    secrets:
      - api_key
    environment:
      - API_KEY_FILE=/run/secrets/api_key
```

## Container Security

### Non-Root Users

All containers run as non-root users:

**Python services:**
```dockerfile
RUN groupadd -r appuser && useradd -r -g appuser appuser
USER appuser
```

**Go service:**
```dockerfile
RUN addgroup -S appuser && adduser -S appuser -G appuser
USER appuser
```

**Node.js service:** (uses built-in `node` user)
```dockerfile
USER node
```

### Resource Limits

All services have CPU and memory limits:

```yaml
deploy:
  resources:
    limits:
      cpus: '0.5'
      memory: 512M
    reservations:
      cpus: '0.25'
      memory: 256M
```

### Security Options

Recommended security options (add to docker-compose.yml):

```yaml
security_opt:
  - no-new-privileges:true
cap_drop:
  - ALL
cap_add:
  - NET_BIND_SERVICE  # Only if needed
```

### Read-Only Root Filesystem

To enable read-only root filesystem:

```yaml
read_only: true
tmpfs:
  - /tmp
  - /var/run
```

## Network Security

### Port Binding

Services are bound to localhost for security:

```yaml
ports:
  - "127.0.0.1:5001:5001"  # Only accessible from localhost
```

**Exception**: Dashboard service on port 5000 can be exposed (it has authentication).

### Network Segmentation

Services communicate via internal Docker network:

```yaml
networks:
  microservices-network:
    driver: bridge
```

External access only through dashboard (entry point).

### SSRF Protection

Dashboard service validates all upstream service URLs:

```python
def validate_service_url(url):
    allowed_hosts = ['time-service', 'system-info-service', 'weather-service']
    # Only internal services allowed
```

### Firewall Configuration

For production, configure firewall:

```bash
# Allow only dashboard port
sudo ufw allow 5000/tcp

# Block direct service access
sudo ufw deny 5001:5003/tcp

# Allow SSH
sudo ufw allow 22/tcp

# Enable firewall
sudo ufw enable
```

## Security Monitoring

### Prometheus Metrics

Security metrics exposed:

```
# Authentication failures
dashboard_service_auth_failures_total{endpoint="/api/aggregate",reason="invalid"}
time_service_auth_failures_total{endpoint="/api/time",reason="missing"}
system_info_service_auth_failures_total{endpoint="/api/sysinfo",reason="invalid"}

# HTTP requests
*_service_http_requests_total{endpoint="/api/*",method="GET",status="401"}
```

### Security Logging

Security events are logged:

```python
security_logger.warning(f'Invalid API key from {request.remote_addr} to {request.endpoint}')
```

Log locations:
- Container stdout/stderr (captured by Docker)
- Can be forwarded to centralized logging (Loki, ELK)

### Alerting

Add security alerts to `monitoring/alert-rules.yml`:

```yaml
groups:
  - name: security_alerts
    rules:
      - alert: HighAuthFailureRate
        expr: rate(auth_failures_total[5m]) > 10
        for: 2m
        labels:
          severity: critical
        annotations:
          summary: "High authentication failure rate detected"
          description: "More than 10 auth failures per second for 2 minutes"
```

## Production Deployment

### Pre-Deployment Checklist

- [ ] Generate strong secrets using `generate-secrets.sh`
- [ ] Review `.env` file and ensure it's not in version control
- [ ] Change Grafana default password
- [ ] Enable HTTPS/TLS (set `HTTPS_ENABLED=True`)
- [ ] Configure SSL certificates
- [ ] Set up centralized logging
- [ ] Configure backup for secrets
- [ ] Set up monitoring alerts
- [ ] Enable firewall rules
- [ ] Review and harden security headers
- [ ] Perform security scan (Trivy, Snyk)
- [ ] Test authentication on all endpoints
- [ ] Configure rate limiting with Redis
- [ ] Set up log rotation

### HTTPS/TLS Configuration

1. Obtain SSL certificates:
   ```bash
   # Using Let's Encrypt
   certbot certonly --standalone -d your-domain.com
   ```

2. Update environment:
   ```bash
   HTTPS_ENABLED=True
   ```

3. Add reverse proxy (Nginx):
   ```nginx
   server {
       listen 443 ssl http2;
       server_name your-domain.com;
       
       ssl_certificate /etc/letsencrypt/live/your-domain.com/fullchain.pem;
       ssl_certificate_key /etc/letsencrypt/live/your-domain.com/privkey.pem;
       
       location / {
           proxy_pass http://localhost:5000;
           proxy_set_header Host $host;
           proxy_set_header X-Real-IP $remote_addr;
       }
   }
   ```

### Security Hardening

Additional hardening steps:

1. **Enable Docker Content Trust:**
   ```bash
   export DOCKER_CONTENT_TRUST=1
   ```

2. **Use secrets management:**
   - AWS Secrets Manager
   - HashiCorp Vault
   - Kubernetes Secrets

3. **Enable audit logging:**
   - System audit logs (auditd)
   - Docker events logging
   - Application audit trail

4. **Implement WAF:**
   - ModSecurity
   - AWS WAF
   - Cloudflare WAF

5. **Set up IDS/IPS:**
   - Fail2ban for brute force protection
   - OSSEC for intrusion detection

## Security Checklist

### Development

- [x] All services use non-root users
- [x] Debug mode disabled in all services
- [x] Security headers configured
- [x] Input validation implemented
- [x] Output sanitization implemented
- [x] API key authentication enabled
- [x] Secrets in environment variables
- [x] Production servers (Gunicorn) configured
- [x] Error messages don't leak sensitive info
- [x] Security logging implemented

### Pre-Production

- [ ] Strong secrets generated
- [ ] Secrets stored securely (not in code)
- [ ] TLS/HTTPS certificates configured
- [ ] Rate limiting configured with Redis
- [ ] Centralized logging set up
- [ ] Security monitoring alerts configured
- [ ] Backup strategy for secrets
- [ ] Firewall rules configured
- [ ] Security scan completed (no HIGH/CRITICAL)
- [ ] Penetration testing performed

### Production

- [ ] All services running with resource limits
- [ ] Read-only root filesystem enabled
- [ ] Seccomp profiles applied
- [ ] Network segmentation implemented
- [ ] Regular security updates scheduled
- [ ] Incident response plan documented
- [ ] Security audit logs reviewed regularly
- [ ] Secrets rotation policy established (90 days)
- [ ] Disaster recovery tested
- [ ] Compliance requirements met (GDPR, HIPAA, etc.)

## Reporting Security Issues

If you discover a security vulnerability:

1. **DO NOT** create a public GitHub issue
2. Email security concerns to: security@your-domain.com
3. Include:
   - Description of the vulnerability
   - Steps to reproduce
   - Potential impact
   - Suggested fix (if any)

We will respond within 48 hours and work with you to address the issue.

## Security Resources

- [OWASP Top 10](https://owasp.org/www-project-top-ten/)
- [CWE Top 25](https://cwe.mitre.org/top25/)
- [Docker Security Best Practices](https://docs.docker.com/engine/security/)
- [Kubernetes Security](https://kubernetes.io/docs/concepts/security/)
- [NIST Cybersecurity Framework](https://www.nist.gov/cyberframework)

## License

This security configuration is part of the microservices project and subject to the same license.
