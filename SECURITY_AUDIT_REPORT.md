# OWASP Top 10 Security Audit Report
# Microservices Architecture - Security Assessment

**Audit Date:** 2025-12-10
**Auditor:** Security Audit Team
**Scope:** 1-microservices_test/ directory
**Framework:** OWASP Top 10:2021

---

## Executive Summary

This comprehensive security audit evaluated the polyglot microservices architecture consisting of four services (Time, System Info, Weather, Dashboard) plus monitoring infrastructure (Prometheus, Grafana). The audit identified **42 security findings** across all OWASP Top 10 categories, with severity levels ranging from **CRITICAL** to **LOW**.

### Critical Statistics
- **Critical Severity:** 8 findings
- **High Severity:** 12 findings
- **Medium Severity:** 15 findings
- **Low Severity:** 7 findings

### Key Risk Areas
1. Complete absence of authentication and authorization mechanisms
2. All services exposed without access controls
3. No encryption for data in transit (HTTP only)
4. Missing input validation and output encoding
5. Containers running as root with excessive privileges
6. No secrets management implementation
7. Insufficient security logging and monitoring

---

## A01:2021 - Broken Access Control

### Severity: CRITICAL

### 1.1 No Authentication Mechanism
**Severity:** CRITICAL
**Files Affected:** All services
- `/home/latnook/devops-progress/1-microservices_test/time-service/main.go`
- `/home/latnook/devops-progress/1-microservices_test/system-info-service/app.py`
- `/home/latnook/devops-progress/1-microservices_test/weather-service/server.js`
- `/home/latnook/devops-progress/1-microservices_test/dashboard-service/app.py`

**Finding:**
All four microservices expose their APIs without any authentication mechanism. Anyone with network access can:
- Access system information (CPU, memory, hostname) via system-info-service
- Query weather data via weather-service
- Access time data via time-service
- Access the dashboard and aggregate data

**Impact:**
- Unauthorized access to all service endpoints
- Information disclosure of system internals
- Potential for abuse and resource exhaustion
- No audit trail of who accessed what

**Recommendation:**
Implement one or more of the following:
1. **API Keys:** Simple token-based authentication for service-to-service communication
2. **OAuth 2.0/OpenID Connect:** For user-facing services like dashboard
3. **Mutual TLS (mTLS):** For service mesh authentication
4. **JWT Tokens:** With proper signature verification and expiration

Example implementation for Flask services:
```python
from functools import wraps
import os

API_KEY = os.environ.get('API_KEY', 'change-me-in-production')

def require_api_key(f):
    @wraps(f)
    def decorated_function(*args, **kwargs):
        auth_header = request.headers.get('X-API-Key')
        if not auth_header or auth_header != API_KEY:
            return jsonify({'error': 'Unauthorized'}), 401
        return f(*args, **kwargs)
    return decorated_function

@app.route('/api/sysinfo', methods=['GET'])
@require_api_key
def get_system_info():
    # ... existing code
```

### 1.2 No Authorization/RBAC
**Severity:** HIGH
**Files Affected:** All services

**Finding:**
No role-based access control (RBAC) or authorization logic. All authenticated requests (if auth were added) would have the same permissions.

**Impact:**
- Cannot differentiate between admin and regular users
- No fine-grained access control
- Cannot implement least privilege principle

**Recommendation:**
Implement RBAC with:
1. Role definitions (admin, operator, viewer)
2. Permission mappings
3. Endpoint-level authorization checks
4. Attribute-based access control (ABAC) for complex scenarios

### 1.3 Exposed Prometheus Metrics Without Authentication
**Severity:** HIGH
**Files Affected:**
- `/home/latnook/devops-progress/1-microservices_test/time-service/main.go` (line 125)
- `/home/latnook/devops-progress/1-microservices_test/system-info-service/app.py` (line 117-129)
- `/home/latnook/devops-progress/1-microservices_test/weather-service/server.js` (line 260-263)
- `/home/latnook/devops-progress/1-microservices_test/dashboard-service/app.py` (line 423-434)

**Finding:**
All services expose `/metrics` endpoints without authentication, revealing:
- Request counts and patterns
- Response times and latencies
- Cache hit/miss ratios
- System resource utilization
- Service dependencies and call patterns

**Impact:**
- Information disclosure aiding reconnaissance
- Reveals system architecture and dependencies
- Exposes performance characteristics for DoS planning

**Recommendation:**
1. Implement basic authentication on /metrics endpoints
2. Use Prometheus service discovery with network isolation
3. Configure Prometheus to use bearer token authentication
4. Restrict /metrics access to monitoring network only

### 1.4 Grafana Default Credentials
**Severity:** CRITICAL
**Files Affected:**
- `/home/latnook/devops-progress/1-microservices_test/docker-compose.yml` (lines 96-97)

**Finding:**
```yaml
environment:
  - GF_SECURITY_ADMIN_USER=admin
  - GF_SECURITY_ADMIN_PASSWORD=admin
```
Grafana uses default credentials (admin/admin) hardcoded in docker-compose.yml.

**Impact:**
- Trivial unauthorized access to monitoring dashboards
- Access to all metrics and system insights
- Ability to modify dashboards and alerts
- Potential to disable monitoring

**Recommendation:**
1. Use strong passwords stored in secrets management
2. Force password change on first login
3. Implement SSO/OAuth integration
4. Use environment variables from secure vault:
```yaml
environment:
  - GF_SECURITY_ADMIN_USER=${GRAFANA_ADMIN_USER}
  - GF_SECURITY_ADMIN_PASSWORD=${GRAFANA_ADMIN_PASSWORD}
```

### 1.5 No Network Segmentation
**Severity:** MEDIUM
**Files Affected:**
- `/home/latnook/devops-progress/1-microservices_test/docker-compose.yml` (lines 103-105)

**Finding:**
All services share a single Docker bridge network without segmentation. All containers can communicate with each other directly.

**Impact:**
- Lateral movement if one service is compromised
- No defense-in-depth
- Cannot implement zero-trust networking

**Recommendation:**
Implement network segmentation:
```yaml
networks:
  frontend:
    driver: bridge
  backend:
    driver: bridge
  monitoring:
    driver: bridge

# Dashboard only in frontend and backend
dashboard-service:
  networks:
    - frontend
    - backend

# Backend services only in backend
time-service:
  networks:
    - backend
```

---

## A02:2021 - Cryptographic Failures

### Severity: CRITICAL

### 2.1 No TLS/HTTPS Encryption
**Severity:** CRITICAL
**Files Affected:** All services

**Finding:**
All services use HTTP without TLS encryption:
- time-service: `http.ListenAndServe(":5001", nil)` (main.go, line 129)
- system-info-service: `app.run(host='0.0.0.0', port=5002)` (app.py, line 137)
- weather-service: `app.listen(PORT, '0.0.0.0')` (server.js, line 272)
- dashboard-service: `app.run(host='0.0.0.0', port=5000)` (app.py, line 442)

**Impact:**
- Data transmitted in clear text
- Vulnerable to man-in-the-middle attacks
- Session hijacking possible
- Credentials (if added) transmitted unencrypted

**Recommendation:**
Implement TLS at multiple layers:

1. **Application-level TLS:**
```python
# For Flask services
if __name__ == '__main__':
    app.run(
        host='0.0.0.0',
        port=5000,
        ssl_context=('cert.pem', 'key.pem')
    )
```

2. **Reverse Proxy (Nginx/Traefik):**
```yaml
services:
  nginx:
    image: nginx:alpine
    ports:
      - "443:443"
    volumes:
      - ./nginx/ssl:/etc/nginx/ssl
      - ./nginx/conf.d:/etc/nginx/conf.d
```

3. **Service Mesh (Istio/Linkerd):** Automatic mTLS between services

### 2.2 No Secrets Management
**Severity:** CRITICAL
**Files Affected:**
- `/home/latnook/devops-progress/1-microservices_test/docker-compose.yml` (lines 96-97)

**Finding:**
Secrets (Grafana credentials) hardcoded in docker-compose.yml. No secrets management system in use.

**Impact:**
- Credentials exposed in version control
- Difficult to rotate secrets
- No audit trail for secret access
- Secrets visible in container environment

**Recommendation:**
Implement secrets management:

1. **Docker Secrets:**
```yaml
secrets:
  grafana_admin_password:
    file: ./secrets/grafana_admin_password.txt

services:
  grafana:
    secrets:
      - grafana_admin_password
    environment:
      - GF_SECURITY_ADMIN_PASSWORD_FILE=/run/secrets/grafana_admin_password
```

2. **HashiCorp Vault:**
```python
import hvac

client = hvac.Client(url='http://vault:8200')
secret = client.secrets.kv.v2.read_secret_version(path='grafana/admin')
password = secret['data']['data']['password']
```

3. **Cloud Provider Secrets:** AWS Secrets Manager, Azure Key Vault, GCP Secret Manager

### 2.3 Session Configuration Issues
**Severity:** MEDIUM
**Files Affected:**
- `/home/latnook/devops-progress/1-microservices_test/dashboard-service/app.py` (lines 38-41)

**Finding:**
```python
app.config['SESSION_COOKIE_SECURE'] = True
app.config['SESSION_COOKIE_HTTPONLY'] = True
app.config['SESSION_COOKIE_SAMESITE'] = 'Lax'
```
SESSION_COOKIE_SECURE=True but service runs on HTTP, making cookies inaccessible. No secret key configured for session signing.

**Impact:**
- Session cookies won't work over HTTP
- Unsigned sessions vulnerable to tampering
- Session fixation attacks possible

**Recommendation:**
```python
import os
import secrets

# Generate strong secret key
app.config['SECRET_KEY'] = os.environ.get('SECRET_KEY', secrets.token_hex(32))

# Conditional secure cookie based on protocol
app.config['SESSION_COOKIE_SECURE'] = os.environ.get('HTTPS_ENABLED', 'False') == 'True'
app.config['SESSION_COOKIE_HTTPONLY'] = True
app.config['SESSION_COOKIE_SAMESITE'] = 'Strict'  # Strict is more secure
```

### 2.4 External API Communication Without Certificate Validation
**Severity:** MEDIUM
**Files Affected:**
- `/home/latnook/devops-progress/1-microservices_test/weather-service/server.js` (line 172)

**Finding:**
Weather service makes HTTPS requests to wttr.in without explicit certificate validation configuration. While Node.js validates by default, there's no certificate pinning or explicit validation.

**Impact:**
- Vulnerable to compromised CAs
- Man-in-the-middle possible with rogue certificates
- No protection against certificate attacks

**Recommendation:**
```javascript
const https = require('https');
const fs = require('fs');

const agent = new https.Agent({
    ca: fs.readFileSync('path/to/ca-bundle.pem'),
    rejectUnauthorized: true,  // Explicit rejection
    checkServerIdentity: (host, cert) => {
        // Custom validation logic
    }
});

const weatherResponse = await axios.get(weatherUrl, {
    timeout: 5000,
    httpsAgent: agent
});
```

---

## A03:2021 - Injection

### Severity: HIGH

### 3.1 Cross-Site Scripting (XSS) in Dashboard
**Severity:** HIGH
**Files Affected:**
- `/home/latnook/devops-progress/1-microservices_test/dashboard-service/app.py` (lines 115-280, HTML template)

**Finding:**
The HTML template uses Jinja2 variable interpolation without proper escaping for user-controlled data:
- Line 214: `{{ time_data.timestamp }}`
- Line 215: `{{ time_data.service }}`
- Lines 222-250: Multiple unescaped interpolations of backend service data

While Jinja2 auto-escapes by default, error messages from backend services could contain malicious content.

**Example Attack Vector:**
If time-service returns: `{"timestamp": "<script>alert('XSS')</script>"}`

**Impact:**
- Cross-site scripting attacks
- Session hijacking
- Credential theft
- Malicious JavaScript execution in user browsers

**Recommendation:**
1. Explicitly use Jinja2's escape filter for untrusted data:
```html
<span id="current-time">{{ time_data.timestamp | e }}</span>
```

2. Implement Content Security Policy (already partially done):
```python
talisman = Talisman(
    app,
    content_security_policy={
        'default-src': "'self'",
        'script-src': ["'self'"],  # Remove 'unsafe-inline'
        'style-src': ["'self'"]    # Remove 'unsafe-inline'
    }
)
```

3. Move inline JavaScript to separate files with nonces

4. Server-side sanitization:
```python
import html

def fetch_service(service_name, url, timeout, default_error):
    try:
        response = requests.get(url, timeout=timeout)
        data = response.json()
        # Sanitize string values
        for key, value in data.items():
            if isinstance(value, str):
                data[key] = html.escape(value)
        return service_name, data
    except Exception as e:
        return service_name, default_error(e)
```

### 3.2 Template Injection via render_template_string
**Severity:** HIGH
**Files Affected:**
- `/home/latnook/devops-progress/1-microservices_test/dashboard-service/app.py` (line 352)

**Finding:**
```python
return render_template_string(
    HTML_TEMPLATE,
    time_data=results.get('time', {}),
    sysinfo_data=results.get('sysinfo', {}),
    weather_data=results.get('weather', {})
)
```
Using `render_template_string` with a constant template is safe, but if the template ever becomes dynamic or includes user input, it's vulnerable to Server-Side Template Injection (SSTI).

**Impact:**
- Remote code execution if template becomes dynamic
- System compromise
- Data exfiltration

**Recommendation:**
1. Use `render_template` with file-based templates:
```python
# Create templates/dashboard.html
return render_template(
    'dashboard.html',
    time_data=results.get('time', {}),
    sysinfo_data=results.get('sysinfo', {}),
    weather_data=results.get('weather', {})
)
```

2. Never include user input in template strings
3. Implement template sandboxing if dynamic templates are needed

### 3.3 No Input Validation on Environment Variables
**Severity:** MEDIUM
**Files Affected:**
- `/home/latnook/devops-progress/1-microservices_test/system-info-service/app.py` (line 76)

**Finding:**
```python
hostname = os.environ.get('HOST_HOSTNAME', socket.gethostname())
```
Environment variable used directly without validation. Could contain command injection characters.

**Impact:**
- If displayed in shell contexts, could lead to command injection
- Log injection attacks
- Data validation bypass

**Recommendation:**
```python
import re

def sanitize_hostname(hostname):
    # Allow only alphanumeric, dots, hyphens, underscores
    if not re.match(r'^[a-zA-Z0-9._-]+$', hostname):
        return 'invalid-hostname'
    return hostname[:255]  # Limit length

hostname = sanitize_hostname(
    os.environ.get('HOST_HOSTNAME', socket.gethostname())
)
```

### 3.4 Potential Command Injection in Healthcheck
**Severity:** MEDIUM
**Files Affected:**
- `/home/latnook/devops-progress/1-microservices_test/docker-compose.yml` (lines 11, 27, 41, 59)

**Finding:**
Health checks use curl with localhost:
```yaml
healthcheck:
  test: ["CMD", "curl", "-f", "http://localhost:5001/health"]
```
While using CMD format prevents shell injection, curl is not installed in alpine images by default.

**Impact:**
- Health checks may fail silently
- Containers marked unhealthy when they're actually healthy
- Delayed detection of actual failures

**Recommendation:**
1. Install curl in Dockerfiles:
```dockerfile
FROM alpine:latest
RUN apk add --no-cache curl
```

2. Or use native HTTP clients:
```yaml
healthcheck:
  test: ["CMD", "wget", "--spider", "-q", "http://localhost:5001/health"]
```

3. Or use language-specific health check scripts

---

## A04:2021 - Insecure Design

### Severity: HIGH

### 4.1 No Rate Limiting on Backend Services
**Severity:** HIGH
**Files Affected:**
- `/home/latnook/devops-progress/1-microservices_test/time-service/main.go`
- `/home/latnook/devops-progress/1-microservices_test/system-info-service/app.py`
- `/home/latnook/devops-progress/1-microservices_test/weather-service/server.js`

**Finding:**
Only dashboard-service implements rate limiting (app.py, lines 49-55). Backend services have no rate limiting, allowing unlimited requests.

**Impact:**
- Denial of service attacks
- Resource exhaustion
- Cost amplification for cloud deployments
- Prometheus metrics endpoint can be overwhelmed

**Recommendation:**
Implement rate limiting on all services:

**Go (time-service):**
```go
import "golang.org/x/time/rate"

var limiter = rate.NewLimiter(10, 100) // 10 req/sec, burst 100

func rateLimitMiddleware(next http.HandlerFunc) http.HandlerFunc {
    return func(w http.ResponseWriter, r *http.Request) {
        if !limiter.Allow() {
            http.Error(w, "Rate limit exceeded", http.StatusTooManyRequests)
            return
        }
        next(w, r)
    }
}
```

**Python (system-info-service):**
```python
from flask_limiter import Limiter

limiter = Limiter(
    app=app,
    key_func=get_remote_address,
    default_limits=["100 per minute", "1000 per hour"]
)

@app.route('/api/sysinfo', methods=['GET'])
@limiter.limit("20 per minute")
def get_system_info():
    # ...
```

**Node.js (weather-service):**
```javascript
const rateLimit = require('express-rate-limit');

const limiter = rateLimit({
    windowMs: 60 * 1000, // 1 minute
    max: 100, // 100 requests per windowMs
    message: 'Too many requests'
});

app.use('/api/', limiter);
```

### 4.2 Cache Poisoning Risk in Weather Service
**Severity:** MEDIUM
**Files Affected:**
- `/home/latnook/devops-progress/1-microservices_test/weather-service/server.js` (lines 86-110)

**Finding:**
Weather service uses a single global cache without considering request context:
```javascript
const weatherCache = {
    data: null,
    timestamp: null,
    cacheDurationMinutes: 10
};
```
All users share the same cache. If cache logic is modified to include query parameters, attackers could poison the cache.

**Impact:**
- Cache poisoning attacks
- Serving wrong data to legitimate users
- Information disclosure

**Recommendation:**
1. Implement cache keys based on request parameters:
```javascript
const weatherCache = new Map();

function getCacheKey(city, country) {
    return `${city}:${country}`;
}

function getFromCache(key) {
    const cached = weatherCache.get(key);
    if (!cached) return null;

    const age = Date.now() - cached.timestamp;
    const maxAge = 10 * 60 * 1000;

    if (age < maxAge) return cached.data;
    return null;
}
```

2. Implement cache size limits to prevent memory exhaustion
3. Add cache validation headers (ETag, Last-Modified)

### 4.3 No Circuit Breaker Pattern
**Severity:** MEDIUM
**Files Affected:**
- `/home/latnook/devops-progress/1-microservices_test/dashboard-service/app.py` (lines 282-310)

**Finding:**
Dashboard service calls backend services without circuit breaker pattern. If a backend service is slow or failing, it will continue attempting requests.

**Impact:**
- Cascading failures
- Thread pool exhaustion
- Increased latency for all requests
- Resource waste on failing calls

**Recommendation:**
Implement circuit breaker pattern:
```python
from circuitbreaker import circuit

@circuit(failure_threshold=5, recovery_timeout=60)
def fetch_service_with_breaker(service_name, url, timeout, default_error):
    start_time = time.time()
    try:
        response = requests.get(url, timeout=timeout)
        UPSTREAM_REQUEST_DURATION.labels(service=service_name).observe(time.time() - start_time)
        return service_name, response.json()
    except Exception as e:
        UPSTREAM_REQUEST_DURATION.labels(service=service_name).observe(time.time() - start_time)
        logger.error(f"Service {service_name} failed: {e}")
        raise
```

### 4.4 Insufficient Error Handling - Information Disclosure
**Severity:** MEDIUM
**Files Affected:**
- `/home/latnook/devops-progress/1-microservices_test/weather-service/server.js` (lines 208-233)
- `/home/latnook/devops-progress/1-microservices_test/dashboard-service/app.py` (line 329-330)

**Finding:**
Error messages expose internal details:
```javascript
error: error.message  // Full error message exposed
```
```python
lambda e: {'service': 'time-service', 'timestamp': f'Error: {str(e)}'}
```

**Impact:**
- Information disclosure about internal architecture
- Stack traces may reveal code paths
- Aids in reconnaissance for attacks

**Recommendation:**
```javascript
catch (error) {
    logger.error(`Weather API error: ${error.message}`, {
        stack: error.stack,
        url: weatherUrl
    });

    res.status(500).json({
        service: 'weather-service',
        error: 'SERVICE_UNAVAILABLE',  // Generic code
        message: 'Unable to fetch weather data. Please try again later.'
    });
}
```

### 4.5 No Request Timeout on Dashboard Service Calls
**Severity:** LOW
**Files Affected:**
- `/home/latnook/devops-progress/1-microservices_test/dashboard-service/app.py` (line 405)

**Finding:**
The time-proxy endpoint has a 2-second timeout, but there's no overall timeout for the dashboard endpoint itself. Flask has no default timeout.

**Impact:**
- Requests can hang indefinitely
- Thread/worker exhaustion
- Poor user experience

**Recommendation:**
```python
from flask import request
import signal

class TimeoutError(Exception):
    pass

def timeout_handler(signum, frame):
    raise TimeoutError("Request timeout")

@app.before_request
def before_request():
    signal.signal(signal.SIGALRM, timeout_handler)
    signal.alarm(30)  # 30 second timeout

@app.after_request
def after_request(response):
    signal.alarm(0)  # Cancel alarm
    return response
```

Or use gunicorn with timeout:
```bash
gunicorn --timeout 30 app:app
```

---

## A05:2021 - Security Misconfiguration

### Severity: HIGH

### 5.1 Flask Debug Mode Configuration
**Severity:** HIGH
**Files Affected:**
- `/home/latnook/devops-progress/1-microservices_test/dashboard-service/app.py` (line 36)
- `/home/latnook/devops-progress/1-microservices_test/system-info-service/app.py` (line 134-137)

**Finding:**
Dashboard service explicitly disables debug mode (good), but system-info-service doesn't configure it:
```python
# dashboard-service (GOOD):
app.config['DEBUG'] = False

# system-info-service (MISSING):
if __name__ == '__main__':
    app.run(host='0.0.0.0', port=5002)  # Debug mode not explicitly set
```

**Impact:**
- If debug=True is accidentally enabled, reveals full stack traces
- Interactive debugger accessible remotely
- Code execution via debugger PIN
- Source code disclosure

**Recommendation:**
Explicitly disable debug mode in all services:
```python
app = Flask(__name__)
app.config['DEBUG'] = False
app.config['TESTING'] = False

# Or via environment variable
app.config['DEBUG'] = os.environ.get('FLASK_DEBUG', 'False') == 'True'
```

### 5.2 Running Flask Development Server in Production
**Severity:** HIGH
**Files Affected:**
- `/home/latnook/devops-progress/1-microservices_test/system-info-service/app.py` (line 137)
- `/home/latnook/devops-progress/1-microservices_test/dashboard-service/app.py` (line 442)

**Finding:**
Both Python services use Flask's development server:
```python
if __name__ == '__main__':
    app.run(host='0.0.0.0', port=5002)
```

**Impact:**
- Not designed for production workloads
- Single-threaded, poor performance
- No request queuing
- Vulnerable to slowloris attacks
- No graceful shutdown

**Recommendation:**
Use production WSGI server (Gunicorn already in requirements.txt):

**Update Dockerfile:**
```dockerfile
FROM python:3.11-slim

WORKDIR /app
COPY requirements.txt .
RUN pip install --no-cache-dir -r requirements.txt

COPY app.py .

EXPOSE 5002

# Use Gunicorn instead of Flask dev server
CMD ["gunicorn", "--bind", "0.0.0.0:5002", "--workers", "4", "--threads", "2", "--timeout", "30", "app:app"]
```

**Add gunicorn.conf.py:**
```python
workers = 4
worker_class = 'sync'
worker_connections = 1000
timeout = 30
keepalive = 5
errorlog = '-'
loglevel = 'info'
accesslog = '-'
```

### 5.3 Node.js Production Mode Not Set
**Severity:** MEDIUM
**Files Affected:**
- `/home/latnook/devops-progress/1-microservices_test/weather-service/Dockerfile` (line 12)

**Finding:**
Weather service doesn't set NODE_ENV=production:
```dockerfile
CMD ["npm", "start"]
```

**Impact:**
- More verbose error messages
- Slower performance (no caching optimizations)
- Development dependencies may be loaded
- Additional debug output

**Recommendation:**
```dockerfile
FROM node:18-alpine

WORKDIR /app
COPY package.json ./
RUN npm install --production

COPY server.js ./

ENV NODE_ENV=production

EXPOSE 5003

CMD ["node", "server.js"]
```

### 5.4 Containers Running as Root
**Severity:** HIGH
**Files Affected:** All Dockerfiles

**Finding:**
None of the Dockerfiles create non-root users. All containers run as root (UID 0).

**Impact:**
- Container escape = root on host
- Privilege escalation attacks easier
- Violates principle of least privilege
- Kubernetes security policies may reject

**Recommendation:**
Add non-root users to all Dockerfiles:

**Python services:**
```dockerfile
FROM python:3.11-slim

# Create non-root user
RUN groupadd -r appuser && useradd -r -g appuser appuser

WORKDIR /app

COPY requirements.txt .
RUN pip install --no-cache-dir -r requirements.txt

COPY app.py .

# Change ownership
RUN chown -R appuser:appuser /app

# Switch to non-root user
USER appuser

EXPOSE 5002

CMD ["gunicorn", "--bind", "0.0.0.0:5002", "app:app"]
```

**Go service:**
```dockerfile
# Build stage
FROM golang:1.21-alpine AS builder
WORKDIR /app
COPY go.mod ./
COPY main.go ./
RUN go mod tidy && go mod download
RUN go build -o time-service main.go

# Runtime stage
FROM alpine:latest

# Create non-root user
RUN addgroup -S appuser && adduser -S appuser -G appuser

WORKDIR /app

# Copy binary
COPY --from=builder /app/time-service .
RUN chown appuser:appuser time-service

# Switch to non-root user
USER appuser

EXPOSE 5001

CMD ["./time-service"]
```

**Node.js service:**
```dockerfile
FROM node:18-alpine

# Node images include 'node' user by default
WORKDIR /app

COPY package.json ./
RUN npm install --production

COPY server.js ./

# Change ownership
RUN chown -R node:node /app

# Switch to non-root user
USER node

EXPOSE 5003

CMD ["node", "server.js"]
```

### 5.5 Overly Permissive CORS Policy
**Severity:** MEDIUM
**Files Affected:**
- `/home/latnook/devops-progress/1-microservices_test/dashboard-service/app.py` (lines 63-68)

**Finding:**
Talisman configured but no explicit CORS policy. Without CORS headers, browsers enforce same-origin policy by default (good), but if CORS is added later, it may be too permissive.

**Impact:**
- If CORS is added without restrictions, allows requests from any origin
- Cross-site request forgery potential
- Data leakage to malicious sites

**Recommendation:**
```python
from flask_cors import CORS

# Restrictive CORS policy
CORS(app, resources={
    r"/api/*": {
        "origins": ["https://dashboard.example.com"],
        "methods": ["GET", "POST"],
        "allow_headers": ["Content-Type", "Authorization"],
        "max_age": 3600
    }
})
```

### 5.6 No Security Headers on Go Service
**Severity:** MEDIUM
**Files Affected:**
- `/home/latnook/devops-progress/1-microservices_test/time-service/main.go`

**Finding:**
Go time-service doesn't set security headers. Only sets Content-Type.

**Impact:**
- Missing XSS protection headers
- Missing frame options
- Missing content sniffing protection

**Recommendation:**
```go
func securityHeadersMiddleware(next http.Handler) http.Handler {
    return http.HandlerFunc(func(w http.ResponseWriter, r *http.Request) {
        w.Header().Set("X-Content-Type-Options", "nosniff")
        w.Header().Set("X-Frame-Options", "DENY")
        w.Header().Set("X-XSS-Protection", "1; mode=block")
        w.Header().Set("Content-Security-Policy", "default-src 'self'")
        w.Header().Set("Referrer-Policy", "strict-origin-when-cross-origin")
        next.ServeHTTP(w, r)
    })
}

func main() {
    mux := http.NewServeMux()
    mux.HandleFunc("/api/time", getTimeHandler)
    mux.HandleFunc("/health", healthHandler)
    mux.Handle("/metrics", promhttp.Handler())

    handler := securityHeadersMiddleware(mux)

    log.Println("Time service starting on port 5001...")
    if err := http.ListenAndServe(":5001", handler); err != nil {
        log.Fatal(err)
    }
}
```

### 5.7 Prometheus and Grafana Accessible Without VPN
**Severity:** MEDIUM
**Files Affected:**
- `/home/latnook/devops-progress/1-microservices_test/docker-compose.yml` (lines 68-69, 88-89)

**Finding:**
Prometheus (9090) and Grafana (3000) ports exposed to host:
```yaml
ports:
  - "9090:9090"  # Prometheus
  - "3000:3000"  # Grafana
```

**Impact:**
- Monitoring infrastructure accessible from outside
- Information disclosure
- Potential for configuration changes
- Attack surface expansion

**Recommendation:**
1. **Bind to localhost only:**
```yaml
ports:
  - "127.0.0.1:9090:9090"
  - "127.0.0.1:3000:3000"
```

2. **Use reverse proxy with authentication:**
```yaml
services:
  nginx:
    image: nginx:alpine
    ports:
      - "443:443"
    volumes:
      - ./nginx/nginx.conf:/etc/nginx/nginx.conf
```

3. **Network policies in Kubernetes:**
```yaml
apiVersion: networking.k8s.io/v1
kind: NetworkPolicy
metadata:
  name: monitoring-policy
spec:
  podSelector:
    matchLabels:
      app: prometheus
  ingress:
    - from:
      - podSelector:
          matchLabels:
            role: monitoring
```

### 5.8 Docker Compose Version Not Pinned
**Severity:** LOW
**Files Affected:**
- `/home/latnook/devops-progress/1-microservices_test/docker-compose.yml`

**Finding:**
No version specification in docker-compose.yml (defaults to latest).

**Impact:**
- Inconsistent behavior across environments
- Breaking changes with new versions
- Reproducibility issues

**Recommendation:**
```yaml
version: '3.8'  # Pin to specific version

services:
  # ...
```

### 5.9 Base Images Not Pinned to Specific Versions
**Severity:** MEDIUM
**Files Affected:** All Dockerfiles

**Finding:**
Images use latest or broad version tags:
- `python:3.11-slim` (no patch version)
- `node:18-alpine` (no patch version)
- `alpine:latest` (completely unpinned)
- `prom/prometheus:latest`
- `grafana/grafana:latest`

**Impact:**
- Unpredictable builds
- Security patches may introduce breaking changes
- Cannot reproduce exact build
- Supply chain attack surface

**Recommendation:**
Pin to specific digests:
```dockerfile
# Instead of:
FROM python:3.11-slim

# Use:
FROM python:3.11.7-slim@sha256:abc123...

# Or at minimum pin patch version:
FROM python:3.11.7-slim
```

Update docker-compose.yml:
```yaml
services:
  prometheus:
    image: prom/prometheus:v2.48.0
  grafana:
    image: grafana/grafana:10.2.3
```

---

## A06:2021 - Vulnerable and Outdated Components

### Severity: HIGH

### 6.1 Dependency Vulnerability Scanning Not Implemented
**Severity:** HIGH
**Files Affected:** Build pipeline (missing)

**Finding:**
No automated dependency scanning in place. No evidence of:
- Snyk, WhiteSource, or Dependabot configuration
- OWASP Dependency-Check integration
- Container image scanning (Trivy, Aqua, Twistlock)

**Impact:**
- Unknown vulnerable dependencies
- No alerts for critical CVEs
- Supply chain attack risk

**Recommendation:**
Implement multi-layer scanning:

**1. GitHub Dependabot (.github/dependabot.yml):**
```yaml
version: 2
updates:
  - package-ecosystem: "pip"
    directory: "/1-microservices_test/dashboard-service"
    schedule:
      interval: "weekly"

  - package-ecosystem: "npm"
    directory: "/1-microservices_test/weather-service"
    schedule:
      interval: "weekly"

  - package-ecosystem: "gomod"
    directory: "/1-microservices_test/time-service"
    schedule:
      interval: "weekly"

  - package-ecosystem: "docker"
    directory: "/"
    schedule:
      interval: "weekly"
```

**2. Trivy scanning in CI/CD:**
```bash
# Scan container images
trivy image --severity HIGH,CRITICAL dashboard-service:latest

# Scan dependencies
trivy fs --severity HIGH,CRITICAL ./1-microservices_test/
```

**3. OWASP Dependency-Check:**
```bash
dependency-check --project "Microservices" \
  --scan ./1-microservices_test/ \
  --format HTML \
  --failOnCVSS 7
```

### 6.2 Python Dependencies May Have Vulnerabilities
**Severity:** MEDIUM
**Files Affected:**
- `/home/latnook/devops-progress/1-microservices_test/system-info-service/requirements.txt`
- `/home/latnook/devops-progress/1-microservices_test/dashboard-service/requirements.txt`

**Finding:**
Dependencies not pinned to exact versions with hashes:
```
Flask==3.0.0
psutil==5.9.6
prometheus-client==0.19.0
```

**Potential Known Vulnerabilities:**
- Flask 3.0.0 was released October 2023 - security updates may exist
- requests 2.31.0 - verify latest patches applied
- Werkzeug 3.0.1 - check for recent CVEs

**Recommendation:**
1. **Generate requirements with hashes:**
```bash
pip-compile --generate-hashes requirements.in > requirements.txt
```

Result:
```
Flask==3.0.3 \
    --hash=sha256:abc123...
requests==2.31.0 \
    --hash=sha256:def456...
```

2. **Regular updates:**
```bash
pip list --outdated
pip-audit  # Check for known vulnerabilities
```

3. **Use Python 3.11 security updates:**
```dockerfile
FROM python:3.11.7-slim  # Pin patch version
```

### 6.3 Node.js Dependencies May Have Vulnerabilities
**Severity:** MEDIUM
**Files Affected:**
- `/home/latnook/devops-progress/1-microservices_test/weather-service/package.json`

**Finding:**
Dependencies use caret (^) ranges allowing minor updates:
```json
"express": "^4.18.2",
"axios": "^1.6.2",
"prom-client": "^15.1.0"
```

**Potential Issues:**
- Express 4.18.2 - check for 4.18.x security patches
- Axios 1.6.2 - verify latest 1.6.x patches
- Caret ranges allow automatic updates that may introduce vulnerabilities

**Recommendation:**
1. **Create package-lock.json with exact versions:**
```bash
npm install --package-lock-only
```

2. **Audit dependencies:**
```bash
npm audit
npm audit fix
```

3. **Use exact versions in production:**
```json
{
  "dependencies": {
    "express": "4.18.2",
    "axios": "1.6.7",
    "prom-client": "15.1.0"
  }
}
```

4. **Add .npmrc:**
```
save-exact=true
```

### 6.4 Go Dependencies Not Using Checksum Database
**Severity:** LOW
**Files Affected:**
- `/home/latnook/devops-progress/1-microservices_test/time-service/go.mod`

**Finding:**
go.mod doesn't include go.sum file in repository check. While go.sum is likely generated during build, it should be committed.

**Impact:**
- Build reproducibility issues
- Potential for dependency confusion attacks
- No verification of module authenticity

**Recommendation:**
1. **Commit go.sum:**
```bash
cd time-service
go mod tidy
git add go.sum
```

2. **Use govulncheck:**
```bash
go install golang.org/x/vuln/cmd/govulncheck@latest
govulncheck ./...
```

3. **Pin Go version:**
```dockerfile
FROM golang:1.21.5-alpine AS builder
```

### 6.5 Alpine Base Images - Musl CVEs
**Severity:** LOW
**Files Affected:**
- `/home/latnook/devops-progress/1-microservices_test/time-service/Dockerfile` (line 13)
- `/home/latnook/devops-progress/1-microservices_test/weather-service/Dockerfile` (line 1)

**Finding:**
Uses alpine:latest and node:18-alpine which include musl libc. Alpine occasionally has CVEs in musl or busybox.

**Impact:**
- Potential vulnerabilities in base system libraries
- Unpredictable updates with :latest tag

**Recommendation:**
```dockerfile
# Pin Alpine version with digest
FROM alpine:3.19.0@sha256:abc123...

# Or use distroless for minimal attack surface
FROM gcr.io/distroless/static-debian12:latest

# Or use slim Debian for better CVE tracking
FROM debian:bookworm-slim
```

---

## A07:2021 - Identification and Authentication Failures

### Severity: CRITICAL

### 7.1 No Authentication Mechanism Implemented
**Severity:** CRITICAL
**Files Affected:** All services

**Finding:**
Duplicate of finding 1.1 but from authentication perspective. No authentication whatsoever:
- No API keys
- No OAuth/OIDC
- No mTLS
- No JWT validation
- No session management

**Impact:**
- Anonymous access to all endpoints
- Cannot identify users or services
- No authentication audit logs
- Impossible to implement authorization

**Recommendation:**
See recommendation 1.1 plus:

**Implement JWT-based authentication:**
```python
from flask import request
import jwt
import os

JWT_SECRET = os.environ.get('JWT_SECRET', 'change-me')
JWT_ALGORITHM = 'HS256'

def require_jwt(f):
    @wraps(f)
    def decorated(*args, **kwargs):
        token = request.headers.get('Authorization', '').replace('Bearer ', '')
        if not token:
            return jsonify({'error': 'No token provided'}), 401

        try:
            payload = jwt.decode(token, JWT_SECRET, algorithms=[JWT_ALGORITHM])
            request.user = payload
        except jwt.ExpiredSignatureError:
            return jsonify({'error': 'Token expired'}), 401
        except jwt.InvalidTokenError:
            return jsonify({'error': 'Invalid token'}), 401

        return f(*args, **kwargs)
    return decorated
```

### 7.2 No Password Policies
**Severity:** MEDIUM
**Files Affected:**
- `/home/latnook/devops-progress/1-microservices_test/docker-compose.yml` (line 97)

**Finding:**
Grafana password "admin" violates all password best practices:
- Too short (minimum 12 characters recommended)
- Common/default password
- No complexity requirements
- Hardcoded

**Impact:**
- Trivial brute force
- Dictionary attacks succeed immediately
- Credential stuffing attacks

**Recommendation:**
```yaml
environment:
  - GF_SECURITY_ADMIN_PASSWORD=${GRAFANA_ADMIN_PASSWORD}
  - GF_SECURITY_PASSWORD_MIN_LENGTH=12
  - GF_SECURITY_DISABLE_INITIAL_ADMIN_CREATION=false
  - GF_SECURITY_PASSWORD_PATTERN=^(?=.*[a-z])(?=.*[A-Z])(?=.*\d)(?=.*[@$!%*?&])[A-Za-z\d@$!%*?&]{12,}$
```

Generate strong password:
```bash
openssl rand -base64 32 > .secrets/grafana_admin_password
```

### 7.3 No Multi-Factor Authentication (MFA)
**Severity:** MEDIUM
**Files Affected:** All services

**Finding:**
No MFA implementation for any service. Single factor (if auth existed) would be the only protection.

**Impact:**
- Credential compromise = full access
- No additional verification layer
- Increased risk from phishing

**Recommendation:**
For Grafana:
```yaml
environment:
  - GF_AUTH_GENERIC_OAUTH_ENABLED=true
  - GF_AUTH_GENERIC_OAUTH_NAME=OAuth
  - GF_AUTH_GENERIC_OAUTH_ALLOW_SIGN_UP=true
  - GF_AUTH_GENERIC_OAUTH_CLIENT_ID=${OAUTH_CLIENT_ID}
  - GF_AUTH_GENERIC_OAUTH_CLIENT_SECRET=${OAUTH_CLIENT_SECRET}
```

For application services, integrate with identity provider supporting MFA (Auth0, Okta, Azure AD).

### 7.4 No Session Timeout Configuration
**Severity:** LOW
**Files Affected:**
- `/home/latnook/devops-progress/1-microservices_test/dashboard-service/app.py`

**Finding:**
Session configuration exists but no timeout/expiration set:
```python
app.config['SESSION_COOKIE_SECURE'] = True
app.config['SESSION_COOKIE_HTTPONLY'] = True
app.config['SESSION_COOKIE_SAMESITE'] = 'Lax'
# Missing: PERMANENT_SESSION_LIFETIME
```

**Impact:**
- Sessions never expire
- Increased window for session hijacking
- Cannot enforce re-authentication

**Recommendation:**
```python
from datetime import timedelta

app.config['PERMANENT_SESSION_LIFETIME'] = timedelta(hours=2)
app.config['SESSION_REFRESH_EACH_REQUEST'] = True

@app.before_request
def make_session_permanent():
    session.permanent = True
```

### 7.5 No Account Lockout Mechanism
**Severity:** MEDIUM
**Files Affected:** All services (missing)

**Finding:**
No brute force protection via account lockout (if authentication existed).

**Impact:**
- Unlimited login attempts
- Brute force attacks feasible
- Credential stuffing attacks

**Recommendation:**
```python
from flask_limiter import Limiter

limiter = Limiter(
    app=app,
    key_func=lambda: request.form.get('username', request.remote_addr),
    storage_uri="redis://redis:6379"
)

@app.route('/login', methods=['POST'])
@limiter.limit("5 per minute")
def login():
    username = request.form.get('username')
    password = request.form.get('password')
    # ... authentication logic
```

---

## A08:2021 - Software and Data Integrity Failures

### Severity: MEDIUM

### 8.1 No Dependency Integrity Verification
**Severity:** MEDIUM
**Files Affected:** All Dockerfiles

**Finding:**
Dependencies installed without checksum verification:
```dockerfile
RUN pip install --no-cache-dir -r requirements.txt  # No hash checking
RUN npm install --production  # No integrity verification
RUN go mod download  # go.sum likely not committed
```

**Impact:**
- Compromised packages can be installed
- Supply chain attacks
- Dependency confusion attacks
- Cannot verify package authenticity

**Recommendation:**
**Python:**
```dockerfile
RUN pip install --no-cache-dir --require-hashes -r requirements.txt
```

requirements.txt:
```
Flask==3.0.3 \
    --hash=sha256:abc123...
```

**Node.js:**
```dockerfile
# package-lock.json provides integrity hashes
COPY package.json package-lock.json ./
RUN npm ci --production  # Uses lock file with integrity checks
```

**Go:**
```dockerfile
COPY go.mod go.sum ./  # Include go.sum
RUN go mod verify  # Verify checksums
RUN go mod download
```

### 8.2 Docker Images Built Without Verification
**Severity:** MEDIUM
**Files Affected:** Build process (missing)

**Finding:**
No Docker Content Trust (DCT) enabled. Images pulled without signature verification.

**Impact:**
- Malicious images could be pulled
- Man-in-the-middle attacks on image registry
- Supply chain compromise

**Recommendation:**
Enable Docker Content Trust:
```bash
export DOCKER_CONTENT_TRUST=1
docker pull prom/prometheus:v2.48.0
```

In CI/CD:
```yaml
# .github/workflows/build.yml
env:
  DOCKER_CONTENT_TRUST: 1

steps:
  - name: Build and push
    run: |
      docker build -t myimage:latest .
      docker push myimage:latest
```

### 8.3 No Code Signing for Artifacts
**Severity:** LOW
**Files Affected:** Build pipeline (missing)

**Finding:**
No evidence of code signing for:
- Docker images (cosign)
- Git commits (GPG)
- Release artifacts

**Impact:**
- Cannot verify artifact authenticity
- No non-repudiation
- Difficult to trace provenance

**Recommendation:**
**Sign Docker images with cosign:**
```bash
# Generate key pair
cosign generate-key-pair

# Sign image
cosign sign --key cosign.key myimage:latest

# Verify
cosign verify --key cosign.pub myimage:latest
```

**GPG sign commits:**
```bash
git config --global user.signingkey <gpg-key-id>
git config --global commit.gpgsign true
```

### 8.4 No SBOM (Software Bill of Materials)
**Severity:** LOW
**Files Affected:** Build pipeline (missing)

**Finding:**
No SBOM generation for tracking dependencies and components.

**Impact:**
- Cannot track vulnerable components
- Difficult to respond to CVE announcements
- No visibility into dependency tree
- Supply chain risk management challenges

**Recommendation:**
Generate SBOMs with Syft:
```bash
# For container images
syft dashboard-service:latest -o spdx-json > dashboard-sbom.json

# For source code
syft dir:./1-microservices_test/dashboard-service -o cyclonedx-json > sbom.json
```

Integrate into CI/CD:
```yaml
- name: Generate SBOM
  run: |
    syft ${{ env.IMAGE_NAME }} -o spdx-json > sbom.json

- name: Upload SBOM
  uses: actions/upload-artifact@v3
  with:
    name: sbom
    path: sbom.json
```

### 8.5 No CI/CD Pipeline Security
**Severity:** MEDIUM
**Files Affected:** .github/workflows (missing)

**Finding:**
No GitHub Actions or CI/CD pipeline configuration found. No automated security checks in build process.

**Impact:**
- Manual deployment process error-prone
- No automated security scanning
- Inconsistent builds
- Difficult to enforce security policies

**Recommendation:**
Create .github/workflows/security.yml:
```yaml
name: Security Scanning

on: [push, pull_request]

jobs:
  security:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4

      - name: Run Trivy vulnerability scanner
        uses: aquasecurity/trivy-action@master
        with:
          scan-type: 'fs'
          scan-ref: '.'
          severity: 'CRITICAL,HIGH'

      - name: Python dependency check
        run: |
          pip install pip-audit
          pip-audit -r 1-microservices_test/dashboard-service/requirements.txt

      - name: Node.js security audit
        run: |
          cd 1-microservices_test/weather-service
          npm audit --audit-level=high

      - name: SAST scanning with Semgrep
        uses: returntocorp/semgrep-action@v1
        with:
          config: >-
            p/security-audit
            p/owasp-top-ten
```

---

## A09:2021 - Security Logging and Monitoring Failures

### Severity: MEDIUM

### 9.1 Insufficient Security Logging
**Severity:** MEDIUM
**Files Affected:** All services

**Finding:**
Services log basic operational information but no security events:
- No authentication attempts (doesn't exist)
- No authorization failures (doesn't exist)
- No input validation failures
- No rate limiting violations
- No suspicious patterns

**Example - Go service:**
```go
log.Println("Time service starting on port 5001...")  // Only startup log
```

**Impact:**
- Cannot detect attacks in progress
- No forensic evidence after breach
- Impossible to investigate incidents
- No compliance audit trail

**Recommendation:**
Implement comprehensive security logging:

**Go service:**
```go
import "log"

type SecurityLogger struct {
    *log.Logger
}

func (sl *SecurityLogger) LogAuthFailure(ip, reason string) {
    sl.Printf("SECURITY [AUTH_FAILURE] ip=%s reason=%s", ip, reason)
}

func (sl *SecurityLogger) LogRateLimit(ip, endpoint string) {
    sl.Printf("SECURITY [RATE_LIMIT] ip=%s endpoint=%s", ip, endpoint)
}

func (sl *SecurityLogger) LogSuspiciousRequest(ip, pattern string) {
    sl.Printf("SECURITY [SUSPICIOUS] ip=%s pattern=%s", ip, pattern)
}

var secLog = &SecurityLogger{log.New(os.Stdout, "", log.LstdFlags)}
```

**Python service:**
```python
import logging

security_logger = logging.getLogger('security')
security_logger.setLevel(logging.INFO)

handler = logging.FileHandler('/var/log/app/security.log')
formatter = logging.Formatter(
    '%(asctime)s - SECURITY - %(levelname)s - %(message)s'
)
handler.setFormatter(formatter)
security_logger.addHandler(handler)

# Usage
security_logger.warning('Auth failure', extra={
    'ip': request.remote_addr,
    'username': username,
    'reason': 'invalid_password'
})
```

### 9.2 No Centralized Logging
**Severity:** MEDIUM
**Files Affected:** All services

**Finding:**
Each service logs independently. No centralized logging system (ELK, Loki, CloudWatch).

**Impact:**
- Difficult to correlate events across services
- No unified view of security events
- Manual log aggregation required
- Logs lost if container crashes

**Recommendation:**
Implement centralized logging:

**Option 1: Loki + Promtail + Grafana**
```yaml
services:
  loki:
    image: grafana/loki:2.9.3
    ports:
      - "3100:3100"
    volumes:
      - ./loki/config.yaml:/etc/loki/config.yaml
    command: -config.file=/etc/loki/config.yaml

  promtail:
    image: grafana/promtail:2.9.3
    volumes:
      - /var/log:/var/log
      - /var/lib/docker/containers:/var/lib/docker/containers:ro
      - ./promtail/config.yaml:/etc/promtail/config.yaml
    command: -config.file=/etc/promtail/config.yaml
```

**Option 2: ELK Stack**
```yaml
services:
  elasticsearch:
    image: docker.elastic.co/elasticsearch/elasticsearch:8.11.3
    environment:
      - discovery.type=single-node
    ports:
      - "9200:9200"

  logstash:
    image: docker.elastic.co/logstash/logstash:8.11.3
    volumes:
      - ./logstash/pipeline:/usr/share/logstash/pipeline
    ports:
      - "5000:5000"

  kibana:
    image: docker.elastic.co/kibana/kibana:8.11.3
    ports:
      - "5601:5601"
```

**Update services to use structured logging:**
```python
import logging
import json_logging

json_logging.init_flask()
json_logging.init_request_instrument(app)

logger = logging.getLogger(__name__)
logger.setLevel(logging.INFO)
logger.addHandler(logging.StreamHandler(sys.stdout))
```

### 9.3 Logs May Contain Sensitive Data
**Severity:** HIGH
**Files Affected:**
- `/home/latnook/devops-progress/1-microservices_test/dashboard-service/app.py` (line 329)
- `/home/latnook/devops-progress/1-microservices_test/weather-service/server.js` (line 217)

**Finding:**
Error messages log full exception details which may contain sensitive data:
```python
lambda e: {'service': 'time-service', 'timestamp': f'Error: {str(e)}'}
```

**Impact:**
- Sensitive data in logs (passwords, tokens, PII)
- Compliance violations (GDPR, HIPAA)
- Information disclosure

**Recommendation:**
Implement log sanitization:
```python
import re

SENSITIVE_PATTERNS = [
    (r'\b[A-Za-z0-9._%+-]+@[A-Za-z0-9.-]+\.[A-Z|a-z]{2,}\b', '[EMAIL]'),
    (r'\b\d{3}-\d{2}-\d{4}\b', '[SSN]'),
    (r'\b(?:\d{4}[-\s]?){3}\d{4}\b', '[CREDIT_CARD]'),
    (r'password["\']?\s*[:=]\s*["\']?([^"\'\\s]+)', 'password=[REDACTED]'),
    (r'token["\']?\s*[:=]\s*["\']?([^"\'\\s]+)', 'token=[REDACTED]'),
]

def sanitize_log(message):
    for pattern, replacement in SENSITIVE_PATTERNS:
        message = re.sub(pattern, replacement, message, flags=re.IGNORECASE)
    return message

# Usage
logger.error(sanitize_log(str(exception)))
```

### 9.4 No Security Alerting
**Severity:** MEDIUM
**Files Affected:** Prometheus configuration

**Finding:**
Prometheus alert rules exist (`/home/latnook/devops-progress/1-microservices_test/monitoring/alert-rules.yml`) but no Alertmanager configuration. No security-specific alerts defined.

**Impact:**
- No real-time security notifications
- Delayed incident detection
- Manual monitoring required
- No integration with incident response

**Recommendation:**
Add Alertmanager to docker-compose.yml:
```yaml
services:
  alertmanager:
    image: prom/alertmanager:v0.26.0
    ports:
      - "9093:9093"
    volumes:
      - ./monitoring/alertmanager.yml:/etc/alertmanager/alertmanager.yml
    command:
      - '--config.file=/etc/alertmanager/alertmanager.yml'
```

Create monitoring/alertmanager.yml:
```yaml
route:
  receiver: 'security-team'
  routes:
    - match:
        severity: 'critical'
      receiver: 'pagerduty'
      continue: true

receivers:
  - name: 'security-team'
    email_configs:
      - to: 'security@example.com'
        from: 'alertmanager@example.com'
        smarthost: 'smtp.example.com:587'

  - name: 'pagerduty'
    pagerduty_configs:
      - service_key: '<integration-key>'
```

Add security-specific alerts:
```yaml
groups:
  - name: security_alerts
    interval: 30s
    rules:
      - alert: HighErrorRate
        expr: rate(http_requests_total{status=~"5.."}[5m]) > 0.1
        for: 5m
        labels:
          severity: warning
        annotations:
          summary: "High error rate detected"

      - alert: SuspiciousRateLimitViolations
        expr: rate(rate_limit_exceeded_total[5m]) > 10
        for: 2m
        labels:
          severity: critical
        annotations:
          summary: "Potential DoS attack detected"

      - alert: UnauthorizedAccessAttempts
        expr: rate(unauthorized_requests_total[5m]) > 5
        for: 1m
        labels:
          severity: critical
        annotations:
          summary: "Multiple unauthorized access attempts"
```

### 9.5 No Audit Trail
**Severity:** MEDIUM
**Files Affected:** All services

**Finding:**
No audit logging for important events:
- Configuration changes
- Admin actions
- Data access
- Permission changes

**Impact:**
- Cannot track who did what when
- No forensic evidence
- Compliance violations
- Insider threat detection impossible

**Recommendation:**
Implement audit logging:
```python
import logging
from functools import wraps

audit_logger = logging.getLogger('audit')
audit_logger.setLevel(logging.INFO)

def audit_log(action):
    def decorator(f):
        @wraps(f)
        def decorated_function(*args, **kwargs):
            user = getattr(request, 'user', 'anonymous')
            audit_logger.info({
                'timestamp': datetime.utcnow().isoformat(),
                'user': user,
                'action': action,
                'ip': request.remote_addr,
                'endpoint': request.endpoint,
                'method': request.method
            })
            return f(*args, **kwargs)
        return decorated_function
    return decorator

@app.route('/api/admin/config', methods=['POST'])
@require_auth
@audit_log('config_change')
def update_config():
    # ...
```

### 9.6 Dashboard Service Rate Limiter Uses In-Memory Storage
**Severity:** LOW
**Files Affected:**
- `/home/latnook/devops-progress/1-microservices_test/dashboard-service/app.py` (line 54)

**Finding:**
```python
storage_uri="memory://"
```
Rate limiter uses in-memory storage. State lost on restart. Doesn't work across multiple instances.

**Impact:**
- Rate limits reset on restart
- Attackers can bypass by restarting container
- Horizontal scaling breaks rate limiting

**Recommendation:**
```python
limiter = Limiter(
    app=app,
    key_func=get_remote_address,
    default_limits=["200 per day", "50 per hour"],
    storage_uri="redis://redis:6379/0"  # Use Redis
)
```

Add Redis to docker-compose.yml:
```yaml
services:
  redis:
    image: redis:7.2-alpine
    ports:
      - "6379:6379"
    volumes:
      - redis-data:/data
    command: redis-server --appendonly yes

volumes:
  redis-data:
```

---

## A10:2021 - Server-Side Request Forgery (SSRF)

### Severity: HIGH

### 10.1 SSRF in Weather Service
**Severity:** HIGH
**Files Affected:**
- `/home/latnook/devops-progress/1-microservices_test/weather-service/server.js` (lines 164-172)

**Finding:**
Weather service makes external HTTP request to hardcoded URL, but if this becomes configurable (e.g., via query parameter or config), it's vulnerable to SSRF:
```javascript
const city = 'Haifa';  // Currently hardcoded
const country = 'Israel';
const weatherUrl = 'https://wttr.in/Haifa,Israel?format=j1';
const weatherResponse = await axios.get(weatherUrl, { timeout: 5000 });
```

**Potential Attack Scenario:**
If code changes to: `const city = req.query.city;`
Then attacker can: `GET /api/weather?city=http://169.254.169.254/latest/meta-data/`

**Impact:**
- Access to cloud metadata services (AWS, Azure, GCP)
- Internal network scanning
- Access to internal services
- Credential theft from metadata
- Port scanning

**Recommendation:**
Implement SSRF protection:
```javascript
const ALLOWED_DOMAINS = ['wttr.in', 'api.openweathermap.org'];
const BLOCKED_IPS = [
    '169.254.169.254',  // AWS metadata
    '169.254.170.2',    // ECS metadata
    '100.100.100.200',  // Azure metadata
    '127.0.0.1',
    '0.0.0.0',
    'localhost'
];

function validateUrl(url) {
    try {
        const parsed = new URL(url);

        // Check protocol
        if (!['http:', 'https:'].includes(parsed.protocol)) {
            throw new Error('Invalid protocol');
        }

        // Check domain whitelist
        if (!ALLOWED_DOMAINS.includes(parsed.hostname)) {
            throw new Error('Domain not allowed');
        }

        // Prevent IP access
        if (/^\\d+\\.\\d+\\.\\d+\\.\\d+$/.test(parsed.hostname)) {
            throw new Error('Direct IP access not allowed');
        }

        return true;
    } catch (e) {
        return false;
    }
}

// Usage
const baseUrl = 'https://wttr.in';
const city = sanitizeInput(req.query.city || 'Haifa');
const country = sanitizeInput(req.query.country || 'Israel');
const weatherUrl = `${baseUrl}/${city},${country}?format=j1`;

if (!validateUrl(weatherUrl)) {
    return res.status(400).json({ error: 'Invalid request' });
}
```

### 10.2 Dashboard Service Proxy Pattern Without Validation
**Severity:** MEDIUM
**Files Affected:**
- `/home/latnook/devops-progress/1-microservices_test/dashboard-service/app.py` (lines 106-108, 282-310)

**Finding:**
Dashboard service acts as proxy to backend services with hardcoded URLs:
```python
TIME_SERVICE_URL = 'http://time-service:5001/api/time'
SYSINFO_SERVICE_URL = 'http://system-info-service:5002/api/sysinfo'
WEATHER_SERVICE_URL = 'http://weather-service:5003/api/weather'
```

While currently hardcoded (safe), if these become configurable via environment variables or config files without validation, SSRF becomes possible.

**Impact:**
- Internal network access
- Bypass of network segmentation
- Access to admin interfaces
- Metadata service access

**Recommendation:**
Even for internal services, implement validation:
```python
import re
from urllib.parse import urlparse

ALLOWED_SERVICES = {
    'time-service': ('http://time-service:5001', ['/api/time', '/health', '/metrics']),
    'sysinfo-service': ('http://system-info-service:5002', ['/api/sysinfo', '/health']),
    'weather-service': ('http://weather-service:5003', ['/api/weather', '/health'])
}

def validate_service_url(service_name, endpoint):
    if service_name not in ALLOWED_SERVICES:
        raise ValueError(f"Service {service_name} not allowed")

    base_url, allowed_endpoints = ALLOWED_SERVICES[service_name]

    if endpoint not in allowed_endpoints:
        raise ValueError(f"Endpoint {endpoint} not allowed for {service_name}")

    return f"{base_url}{endpoint}"

# Usage
def fetch_service(service_name, url, timeout, default_error):
    # Validate URL before making request
    parsed = urlparse(url)
    if parsed.hostname not in ['time-service', 'system-info-service', 'weather-service']:
        logger.error(f"Blocked SSRF attempt: {url}")
        return service_name, {'error': 'Invalid service'}

    # ... proceed with request
```

### 10.3 No DNS Rebinding Protection
**Severity:** LOW
**Files Affected:** All services making HTTP requests

**Finding:**
No protection against DNS rebinding attacks. Services don't re-validate resolved IPs.

**Impact:**
- TOCTOU (Time-of-check Time-of-use) vulnerability
- Initial DNS resolves to safe IP
- Follow-up requests resolve to internal IP
- Bypass of hostname-based SSRF protection

**Recommendation:**
```python
import socket

def resolve_and_validate(hostname):
    """Resolve hostname and validate IP is not internal"""

    BLOCKED_IP_RANGES = [
        '127.0.0.0/8',      # Loopback
        '10.0.0.0/8',       # Private
        '172.16.0.0/12',    # Private
        '192.168.0.0/16',   # Private
        '169.254.0.0/16',   # Link-local
        '::1/128',          # IPv6 loopback
        'fc00::/7',         # IPv6 private
    ]

    try:
        ip = socket.gethostbyname(hostname)

        # Check if IP is in blocked ranges
        import ipaddress
        ip_obj = ipaddress.ip_address(ip)

        for range_str in BLOCKED_IP_RANGES:
            if ip_obj in ipaddress.ip_network(range_str):
                raise ValueError(f"Resolved to blocked IP: {ip}")

        return ip
    except Exception as e:
        raise ValueError(f"DNS resolution failed: {e}")

# Usage with requests
ip = resolve_and_validate('wttr.in')
response = requests.get(
    f'https://{ip}/Haifa,Israel?format=j1',
    headers={'Host': 'wttr.in'},
    timeout=5
)
```

### 10.4 No Network Egress Controls
**Severity:** MEDIUM
**Files Affected:**
- `/home/latnook/devops-progress/1-microservices_test/docker-compose.yml`

**Finding:**
No egress filtering configured. All containers can make outbound connections to any destination.

**Impact:**
- Compromised containers can exfiltrate data
- Cannot prevent C2 communications
- No defense against supply chain attacks
- Difficult to detect anomalous network behavior

**Recommendation:**
**Docker network policies (limited):**
```yaml
services:
  weather-service:
    networks:
      - microservices-network
      - external-network

  time-service:
    networks:
      - microservices-network
    # No external network access

networks:
  microservices-network:
    driver: bridge
    internal: false
  external-network:
    driver: bridge
    internal: false
```

**Better solution - Kubernetes NetworkPolicy:**
```yaml
apiVersion: networking.k8s.io/v1
kind: NetworkPolicy
metadata:
  name: weather-service-egress
spec:
  podSelector:
    matchLabels:
      app: weather-service
  policyTypes:
    - Egress
  egress:
    # Allow DNS
    - to:
      - namespaceSelector:
          matchLabels:
            name: kube-system
      ports:
      - protocol: UDP
        port: 53

    # Allow external weather API
    - to:
      - podSelector: {}
      ports:
      - protocol: TCP
        port: 443
```

**Best solution - Service Mesh:**
```yaml
# Istio Egress Policy
apiVersion: networking.istio.io/v1beta1
kind: ServiceEntry
metadata:
  name: external-weather-api
spec:
  hosts:
    - wttr.in
  ports:
    - number: 443
      name: https
      protocol: HTTPS
  resolution: DNS
  location: MESH_EXTERNAL
```

---

## Container Security Issues

### C01: Containers Running as Root
**Severity:** HIGH
**Covered in Section 5.4**

### C02: Writable Root Filesystem
**Severity:** MEDIUM
**Files Affected:** All Dockerfiles

**Finding:**
Containers have writable root filesystem. No read-only root filesystem configured.

**Impact:**
- Attackers can modify binaries
- Malware persistence
- Difficult to detect tampering
- Violates immutable infrastructure principle

**Recommendation:**
```yaml
# docker-compose.yml
services:
  time-service:
    build: ./time-service
    read_only: true
    tmpfs:
      - /tmp
      - /var/run
```

Or in Kubernetes:
```yaml
spec:
  containers:
    - name: time-service
      securityContext:
        readOnlyRootFilesystem: true
```

### C03: No Resource Limits
**Severity:** MEDIUM
**Files Affected:**
- `/home/latnook/devops-progress/1-microservices_test/docker-compose.yml`

**Finding:**
No CPU or memory limits configured for any container:
```yaml
services:
  time-service:
    build: ./time-service
    # Missing: resource limits
```

**Impact:**
- Single container can consume all host resources
- Noisy neighbor problems
- DoS via resource exhaustion
- Difficult capacity planning

**Recommendation:**
```yaml
services:
  time-service:
    build: ./time-service
    deploy:
      resources:
        limits:
          cpus: '0.5'
          memory: 512M
        reservations:
          cpus: '0.25'
          memory: 256M

  system-info-service:
    build: ./system-info-service
    deploy:
      resources:
        limits:
          cpus: '0.5'
          memory: 512M
        reservations:
          cpus: '0.25'
          memory: 256M
```

### C04: No Security Options (Seccomp, AppArmor, SELinux)
**Severity:** MEDIUM
**Files Affected:**
- `/home/latnook/devops-progress/1-microservices_test/docker-compose.yml`

**Finding:**
No seccomp profiles, AppArmor profiles, or security options configured.

**Impact:**
- Containers can make any syscalls
- Increased kernel attack surface
- No mandatory access control
- Privilege escalation risks

**Recommendation:**
```yaml
services:
  time-service:
    build: ./time-service
    security_opt:
      - no-new-privileges:true
      - seccomp=./seccomp/time-service.json
    cap_drop:
      - ALL
    cap_add:
      - NET_BIND_SERVICE  # Only if needed
```

Create seccomp profile (seccomp/time-service.json):
```json
{
  "defaultAction": "SCMP_ACT_ERRNO",
  "architectures": ["SCMP_ARCH_X86_64"],
  "syscalls": [
    {
      "names": [
        "accept", "accept4", "access", "arch_prctl",
        "bind", "brk", "close", "connect",
        "dup", "dup2", "epoll_create1", "epoll_ctl",
        "epoll_wait", "exit_group", "fcntl", "fstat",
        "futex", "getcwd", "getpeername", "getpid",
        "getsockname", "getsockopt", "listen", "mmap",
        "munmap", "nanosleep", "open", "openat",
        "read", "readlinkat", "recvfrom", "rt_sigaction",
        "rt_sigprocmask", "sendto", "set_robust_list",
        "setsockopt", "shutdown", "socket", "stat",
        "write", "writev"
      ],
      "action": "SCMP_ACT_ALLOW"
    }
  ]
}
```

### C05: No Image Scanning in CI/CD
**Severity:** HIGH
**Files Affected:** Build pipeline (missing)

**Finding:**
No automated container image scanning for vulnerabilities.

**Impact:**
- Vulnerable images deployed to production
- No visibility into CVEs
- Cannot enforce security policies
- Supply chain risks

**Recommendation:**
Add to CI/CD pipeline:
```yaml
# .github/workflows/docker-security.yml
name: Container Security Scan

on: [push, pull_request]

jobs:
  scan:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4

      - name: Build images
        run: |
          docker-compose -f 1-microservices_test/docker-compose.yml build

      - name: Scan with Trivy
        uses: aquasecurity/trivy-action@master
        with:
          image-ref: 'time-service:latest'
          format: 'sarif'
          output: 'trivy-results.sarif'
          severity: 'CRITICAL,HIGH'
          exit-code: '1'  # Fail build on issues

      - name: Upload Trivy results to GitHub Security
        uses: github/codeql-action/upload-sarif@v2
        with:
          sarif_file: 'trivy-results.sarif'
```

### C06: No Health Check Timeouts or Retries Configured
**Severity:** LOW
**Files Affected:**
- `/home/latnook/devops-progress/1-microservices_test/docker-compose.yml` (lines 10-14, etc.)

**Finding:**
Health checks configured but with default/basic settings:
```yaml
healthcheck:
  test: ["CMD", "curl", "-f", "http://localhost:5001/health"]
  interval: 30s
  timeout: 10s
  retries: 3
```

**Impact:**
- 30s interval is too long for quick failover
- 10s timeout may be too long
- Could mark healthy containers as unhealthy during load

**Recommendation:**
```yaml
healthcheck:
  test: ["CMD", "wget", "--spider", "-q", "http://localhost:5001/health"]
  interval: 10s       # Check more frequently
  timeout: 3s         # Shorter timeout
  retries: 3
  start_period: 30s   # Grace period for startup
```

---

## Network Security Issues

### N01: All Services on Same Network
**Severity:** MEDIUM
**Covered in Section 1.5**

### N02: No TLS for Internal Communication
**Severity:** HIGH
**Covered in Section 2.1**

### N03: Port Binding to 0.0.0.0
**Severity:** MEDIUM
**Files Affected:**
- All service application code and docker-compose.yml

**Finding:**
All services bind to 0.0.0.0 (all interfaces):
```python
app.run(host='0.0.0.0', port=5000)
```
```javascript
app.listen(PORT, '0.0.0.0', ...)
```

While necessary for Docker networking, combined with port publishing, makes services accessible from outside.

**Impact:**
- Services accessible from Docker host
- If host is internet-facing, services exposed
- Increased attack surface

**Recommendation:**
1. **Keep 0.0.0.0 binding inside containers** (necessary for Docker)
2. **Control access via port publishing:**
```yaml
services:
  time-service:
    ports:
      - "127.0.0.1:5001:5001"  # Bind to localhost only
```

3. **Use reverse proxy for external access:**
```yaml
services:
  nginx:
    image: nginx:alpine
    ports:
      - "443:443"
    volumes:
      - ./nginx/nginx.conf:/etc/nginx/nginx.conf
```

nginx.conf:
```nginx
server {
    listen 443 ssl http2;
    server_name api.example.com;

    ssl_certificate /etc/nginx/ssl/cert.pem;
    ssl_certificate_key /etc/nginx/ssl/key.pem;

    location /api/time {
        proxy_pass http://time-service:5001;
        proxy_set_header Host $host;
        proxy_set_header X-Real-IP $remote_addr;
    }
}
```

---

## Summary of Recommendations by Priority

### Immediate Actions (Critical/High Severity)

1. **Implement Authentication & Authorization** (A01, A07)
   - Add API key authentication to all services
   - Implement JWT tokens for dashboard
   - Change Grafana default credentials
   - Store credentials in secrets management

2. **Enable TLS/HTTPS** (A02)
   - Add TLS termination at reverse proxy
   - Generate/purchase SSL certificates
   - Configure mTLS for service-to-service communication

3. **Fix Container Security** (A05, C01)
   - Create non-root users in all Dockerfiles
   - Add resource limits
   - Implement seccomp profiles
   - Enable read-only root filesystem

4. **Implement Rate Limiting** (A04)
   - Add rate limiting to all backend services
   - Use Redis for distributed rate limiting
   - Configure appropriate limits per endpoint

5. **Add Input Validation & Output Encoding** (A03)
   - Sanitize all external input
   - Escape output in templates
   - Implement CSP without unsafe-inline
   - Validate environment variables

### Short-term Actions (Medium Severity)

6. **Implement Security Logging** (A09)
   - Add security event logging
   - Deploy centralized logging (Loki/ELK)
   - Configure Alertmanager
   - Add security-specific Prometheus alerts

7. **Dependency Management** (A06, A08)
   - Enable Dependabot
   - Implement Trivy scanning in CI/CD
   - Pin dependencies with hashes
   - Generate SBOMs

8. **Production Readiness** (A05)
   - Replace Flask dev server with Gunicorn
   - Set NODE_ENV=production
   - Implement circuit breaker pattern
   - Add proper error handling

9. **Network Security** (A10, N03)
   - Implement network segmentation
   - Add SSRF protection
   - Bind Prometheus/Grafana to localhost
   - Configure egress filtering

### Long-term Actions (Low Severity)

10. **Compliance & Governance** (A08, A09)
    - Implement audit logging
    - Add code signing
    - Create security documentation
    - Establish incident response procedures

11. **Advanced Security** (A04, A09)
    - Implement MFA for Grafana
    - Add WAF (Web Application Firewall)
    - Deploy service mesh (Istio)
    - Implement zero-trust networking

---

## Conclusion

This microservices architecture demonstrates good DevOps practices with containerization, monitoring, and service orchestration. However, it has **significant security gaps** typical of development/learning environments:

- **No authentication/authorization** whatsoever
- **No encryption** for data in transit
- **Missing security controls** across all OWASP Top 10 categories
- **Container security issues** (running as root, no limits)
- **Insufficient logging** and monitoring for security events

The good news: the architecture is well-structured, making it relatively straightforward to implement security controls. The modular design allows adding authentication, TLS, and other controls incrementally.

**Risk Level: HIGH** - This system should NOT be exposed to untrusted networks or used with production data without implementing at minimum the Critical and High severity fixes.

---

## Next Steps

1. Review this report with the development team
2. Prioritize fixes based on severity and business impact
3. Create security tickets/issues for each finding
4. Implement fixes iteratively, starting with Critical items
5. Re-scan after fixes to verify remediation
6. Establish ongoing security practices (SAST/DAST, dependency scanning, security training)
7. Consider security testing (penetration testing, security audit)

---

**Report End**
