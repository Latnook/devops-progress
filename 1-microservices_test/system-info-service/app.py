"""
System Info Service

This microservice collects and provides comprehensive system information about
the host machine and container. It gathers details about the platform, CPU,
memory, and Python environment.

The service is useful for:
- Monitoring infrastructure and resource utilization
- Debugging deployment issues (hostname, platform info)
- Capacity planning (CPU cores, memory availability)
- Verifying container configurations

Includes Prometheus metrics for monitoring request patterns and latency.
"""

from flask import Flask, jsonify, request
import socket
import platform
import os
import psutil
from prometheus_client import Counter, Histogram, generate_latest, CONTENT_TYPE_LATEST
import time
import logging
import re
from functools import wraps

# Configure logging with security events
logging.basicConfig(
    level=logging.INFO,
    format='%(asctime)s - %(name)s - %(levelname)s - %(message)s'
)
logger = logging.getLogger(__name__)
security_logger = logging.getLogger('security')
security_logger.setLevel(logging.WARNING)

app = Flask(__name__)

# Security Configuration
app.config['DEBUG'] = False
app.config['TESTING'] = False

# API Key for authentication
API_KEY = os.environ.get('API_KEY', 'development-key-change-in-production')

if API_KEY == 'development-key-change-in-production':
    logger.warning("⚠️  WARNING: Using default API key. Set API_KEY environment variable for production!")

# ============================================================================
# Security: Authentication and Input Validation
# ============================================================================

def require_api_key(f):
    """
    Decorator to require API key authentication for endpoints.
    """
    @wraps(f)
    def decorated_function(*args, **kwargs):
        auth_header = request.headers.get('X-API-Key')

        if not auth_header:
            security_logger.warning(f'Missing API key from {request.remote_addr} to {request.endpoint}')
            return jsonify({'error': 'Unauthorized', 'message': 'API key required'}), 401

        if auth_header != API_KEY:
            security_logger.warning(f'Invalid API key from {request.remote_addr} to {request.endpoint}')
            return jsonify({'error': 'Unauthorized', 'message': 'Invalid API key'}), 401

        return f(*args, **kwargs)
    return decorated_function


def sanitize_hostname(hostname):
    """
    Sanitize hostname to prevent injection attacks.
    Only allows alphanumeric characters, dots, hyphens, and underscores.
    """
    if not hostname:
        return 'unknown'

    # Remove any potentially dangerous characters
    sanitized = re.sub(r'[^a-zA-Z0-9._-]', '', hostname)

    # Limit length to prevent buffer overflow
    return sanitized[:255] if sanitized else 'unknown'


@app.after_request
def add_security_headers(response):
    """
    Add security headers to all responses.
    """
    response.headers['X-Content-Type-Options'] = 'nosniff'
    response.headers['X-Frame-Options'] = 'DENY'
    response.headers['X-XSS-Protection'] = '1; mode=block'
    response.headers['Referrer-Policy'] = 'strict-origin-when-cross-origin'
    return response


# ============================================================================
# Prometheus Metrics Configuration
# ============================================================================
# These metrics track HTTP request patterns and performance for this service.

# Counter: Tracks total number of HTTP requests
# Labels allow filtering by endpoint, HTTP method, and response status
REQUEST_COUNT = Counter(
    'system_info_service_http_requests_total',
    'Total HTTP requests',
    ['endpoint', 'method', 'status']
)

# Histogram: Measures request duration distribution
# Used to identify slow endpoints and track API performance
REQUEST_DURATION = Histogram(
    'system_info_service_http_request_duration_seconds',
    'HTTP request latency',
    ['endpoint', 'method']
)

# Counter: Track authentication failures
AUTH_FAILURES = Counter(
    'system_info_service_auth_failures_total',
    'Total authentication failures',
    ['endpoint', 'reason']
)

@app.route('/api/sysinfo', methods=['GET'])
@require_api_key
def get_system_info():
    """
    Collects and returns comprehensive system information.

    This endpoint gathers information about both the host machine and the
    container it's running in. It uses environment variables to distinguish
    between the host hostname and container hostname when running in Docker.

    Requires API key authentication via X-API-Key header.

    The response includes:
    - Platform details (OS type, version, architecture)
    - CPU information (logical and physical core counts)
    - Memory statistics (total, available, usage percentage)
    - Python environment version
    - Host and container hostnames

    Environment Variables:
        HOST_HOSTNAME: If set, used as the host machine's hostname. This is
                       typically set by Docker Compose to pass the host's
                       hostname into the container.

    Returns:
        Response: JSON object with comprehensive system information
    """
    start_time = time.time()

    # Get host hostname from environment variable, or fall back to container hostname
    # Docker Compose can set HOST_HOSTNAME to the actual host machine name
    # Sanitize hostnames to prevent injection attacks
    hostname = sanitize_hostname(os.environ.get('HOST_HOSTNAME', socket.gethostname()))
    container_hostname = sanitize_hostname(socket.gethostname())

    # Gather detailed system information using platform and psutil libraries
    system_info = {
        'service': 'system-info-service',
        'hostname': hostname,  # Host machine hostname
        'container_hostname': container_hostname,  # Container's internal hostname
        'platform': platform.system(),  # OS type (Linux, Windows, Darwin)
        'platform_release': platform.release(),  # Kernel/OS version
        'platform_version': platform.version(),  # Detailed version string
        'architecture': platform.machine(),  # CPU architecture (x86_64, arm64, etc.)
        'processor': platform.processor() or 'Unknown',  # Processor name/model
        'python_version': platform.python_version(),  # Python interpreter version
        'cpu_count': psutil.cpu_count(logical=True),  # Logical CPU cores (with hyperthreading)
        'cpu_count_physical': psutil.cpu_count(logical=False),  # Physical CPU cores
        'memory_total_gb': round(psutil.virtual_memory().total / (1024**3), 2),  # Total RAM in GB
        'memory_available_gb': round(psutil.virtual_memory().available / (1024**3), 2),  # Available RAM in GB
        'memory_percent': psutil.virtual_memory().percent  # Memory usage percentage
    }

    # Record performance metrics
    duration = time.time() - start_time
    REQUEST_DURATION.labels(endpoint='/api/sysinfo', method='GET').observe(duration)
    REQUEST_COUNT.labels(endpoint='/api/sysinfo', method='GET', status='200').inc()

    return jsonify(system_info)

@app.route('/health', methods=['GET'])
def health():
    """
    Health check endpoint for container orchestration and monitoring.

    Used by Docker/Kubernetes health probes and monitoring systems to verify
    the service is running and responsive.

    Returns:
        Response: JSON with status 'healthy'
    """
    return jsonify({'status': 'healthy'})

@app.route('/metrics', methods=['GET'])
def metrics():
    """
    Prometheus metrics endpoint.

    Exposes all collected Prometheus metrics in a format that can be scraped
    by Prometheus server for monitoring and alerting. Metrics include request
    counts, latency histograms, and other performance indicators.

    Returns:
        Response: Prometheus-formatted metrics in plain text
    """
    return generate_latest(), 200, {'Content-Type': CONTENT_TYPE_LATEST}

# ============================================================================
# Application Entry Point
# ============================================================================
if __name__ == '__main__':
    # Run Flask development server on all interfaces, port 5002
    # In production, this would be served by a WSGI server like Gunicorn
    app.run(host='0.0.0.0', port=5002)
