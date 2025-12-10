"""
Dashboard Aggregator Service

This microservice aggregates data from multiple backend services (Time, System Info, and Weather)
and presents them in a unified web dashboard. It uses parallel API calls to optimize performance
and includes Prometheus metrics for monitoring request latency and service health.

Key features:
- Parallel service calls using ThreadPoolExecutor for faster response times
- Prometheus metrics collection for monitoring and alerting
- Responsive HTML dashboard with auto-updating time display
- Fallback error handling for when backend services are unavailable
"""

from flask import Flask, jsonify, render_template_string, request
import requests
from concurrent.futures import ThreadPoolExecutor, as_completed
from prometheus_client import Counter, Histogram, generate_latest, CONTENT_TYPE_LATEST
from flask_limiter import Limiter
from flask_limiter.util import get_remote_address
from flask_talisman import Talisman
import time
import logging
import html
import os
import secrets
from functools import wraps
from datetime import timedelta
import re

# Configure secure logging with separate loggers for security events
logging.basicConfig(
    level=logging.INFO,
    format='%(asctime)s - %(name)s - %(levelname)s - %(message)s'
)
logger = logging.getLogger(__name__)
security_logger = logging.getLogger('security')
security_logger.setLevel(logging.WARNING)

app = Flask(__name__)

# Security: Generate strong secret key for sessions
app.config['SECRET_KEY'] = os.environ.get('DASHBOARD_SECRET_KEY', secrets.token_hex(32))

# Security: Disable debug mode explicitly
app.config['DEBUG'] = False
app.config['TESTING'] = False

# Security: Set secure session configuration
# Only set SECURE cookie if HTTPS is enabled
HTTPS_ENABLED = os.environ.get('HTTPS_ENABLED', 'False') == 'True'
app.config['SESSION_COOKIE_SECURE'] = HTTPS_ENABLED
app.config['SESSION_COOKIE_HTTPONLY'] = True
app.config['SESSION_COOKIE_SAMESITE'] = 'Strict'  # Changed from Lax to Strict for better security
app.config['PERMANENT_SESSION_LIFETIME'] = timedelta(hours=2)

# Security: Prevent template auto-reload
app.config['TEMPLATES_AUTO_RELOAD'] = False

# Security: Set maximum content length (10MB)
app.config['MAX_CONTENT_LENGTH'] = 10 * 1024 * 1024

# API Key for service authentication
API_KEY = os.environ.get('API_KEY', 'development-key-change-in-production')

# Check if running in production mode
if API_KEY == 'development-key-change-in-production':
    logger.warning("⚠️  WARNING: Using default API key. Set API_KEY environment variable for production!")

# Initialize rate limiter to prevent DoS attacks
# Use Redis for distributed rate limiting if available, otherwise memory
RATE_LIMIT_ENABLED = os.environ.get('RATE_LIMIT_ENABLED', 'True') == 'True'
REDIS_URL = os.environ.get('REDIS_URL', 'memory://')

limiter = Limiter(
    app=app,
    key_func=get_remote_address,
    default_limits=["200 per day", "50 per hour"],
    storage_uri=REDIS_URL,
    enabled=RATE_LIMIT_ENABLED
)

# Initialize Talisman for security headers
talisman = Talisman(
    app,
    force_https=HTTPS_ENABLED,
    strict_transport_security=HTTPS_ENABLED,
    strict_transport_security_max_age=31536000,  # 1 year
    content_security_policy={
        'default-src': "'self'",
        'script-src': ["'self'", "'unsafe-inline'"],  # TODO: Move to external JS file with nonce
        'style-src': ["'self'", "'unsafe-inline'"]   # TODO: Move to external CSS file
    },
    content_security_policy_nonce_in=['script-src'],
    referrer_policy='strict-origin-when-cross-origin',
    feature_policy={
        'geolocation': "'none'",
        'microphone': "'none'",
        'camera': "'none'"
    }
)

# ============================================================================
# Security: Authentication and Input Validation
# ============================================================================

def require_api_key(f):
    """
    Decorator to require API key authentication for endpoints.

    Checks for X-API-Key header and validates it against configured API_KEY.
    Logs failed authentication attempts for security monitoring.
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


def sanitize_output(data):
    """
    Sanitize output data to prevent XSS attacks.

    Recursively escapes HTML in string values to prevent injection attacks
    when data from untrusted sources is displayed in the dashboard.
    """
    if isinstance(data, dict):
        return {key: sanitize_output(value) for key, value in data.items()}
    elif isinstance(data, list):
        return [sanitize_output(item) for item in data]
    elif isinstance(data, str):
        return html.escape(data)
    else:
        return data


def validate_service_url(url):
    """
    Validate that service URLs are from allowed internal services only.

    Prevents SSRF attacks by ensuring only whitelisted service hostnames
    can be accessed through the dashboard proxy.
    """
    allowed_hosts = ['time-service', 'system-info-service', 'weather-service']

    # Parse the URL to extract hostname
    if url.startswith('http://'):
        hostname = url.split('//')[1].split(':')[0].split('/')[0]
        return hostname in allowed_hosts

    return False


# ============================================================================
# Prometheus Metrics Configuration
# ============================================================================
# These metrics are collected to monitor dashboard performance and upstream
# service health. They can be scraped by Prometheus for monitoring/alerting.

# Counter: Tracks total number of HTTP requests to this service
# Labels allow filtering by endpoint, HTTP method, and response status
REQUEST_COUNT = Counter(
    'dashboard_service_http_requests_total',
    'Total HTTP requests',
    ['endpoint', 'method', 'status']
)

# Counter: Track authentication failures for security monitoring
AUTH_FAILURES = Counter(
    'dashboard_service_auth_failures_total',
    'Total authentication failures',
    ['endpoint', 'reason']
)

# Histogram: Measures request duration for this service's endpoints
# Used to track API response time and identify slow endpoints
REQUEST_DURATION = Histogram(
    'dashboard_service_http_request_duration_seconds',
    'HTTP request latency',
    ['endpoint', 'method']
)

# Histogram: Measures latency when calling upstream microservices
# Helps identify which backend service is causing slowdowns
UPSTREAM_REQUEST_DURATION = Histogram(
    'dashboard_service_upstream_request_duration_seconds',
    'Upstream service request latency',
    ['service']
)

# ============================================================================
# Backend Service Configuration
# ============================================================================
# These URLs point to the backend microservices in the Docker network.
# Docker Compose automatically resolves these service names to container IPs.
TIME_SERVICE_URL = 'http://time-service:5001/api/time'
SYSINFO_SERVICE_URL = 'http://system-info-service:5002/api/sysinfo'
WEATHER_SERVICE_URL = 'http://weather-service:5003/api/weather'

# ============================================================================
# HTML Dashboard Template
# ============================================================================
# This template renders the aggregated data from all microservices into a
# responsive web dashboard. Includes auto-refresh JavaScript for live time updates.
HTML_TEMPLATE = '''
<!DOCTYPE html>
<html>
<head>
    <title>Microservices Dashboard</title>
    <style>
        body {
            font-family: Arial, sans-serif;
            max-width: 800px;
            margin: 50px auto;
            padding: 20px;
            background-color: #f5f5f5;
        }
        .container {
            background-color: white;
            border-radius: 8px;
            padding: 30px;
            box-shadow: 0 2px 4px rgba(0,0,0,0.1);
        }
        h1 {
            color: #333;
            text-align: center;
        }
        .service-box {
            background-color: #e8f4f8;
            border-left: 4px solid #2196F3;
            padding: 15px;
            margin: 20px 0;
            border-radius: 4px;
        }
        .service-title {
            font-weight: bold;
            color: #1976D2;
            margin-bottom: 10px;
        }
        .data-item {
            margin: 5px 0;
        }
        .label {
            font-weight: bold;
            color: #555;
        }
        .refresh-btn {
            background-color: #4CAF50;
            color: white;
            padding: 10px 20px;
            border: none;
            border-radius: 4px;
            cursor: pointer;
            font-size: 16px;
            display: block;
            margin: 20px auto;
        }
        .refresh-btn:hover {
            background-color: #45a049;
        }
        .cache-badge {
            display: inline-block;
            background-color: #ff9800;
            color: white;
            padding: 2px 8px;
            border-radius: 3px;
            font-size: 12px;
            margin-left: 10px;
        }
        .perf-info {
            background-color: #e8f5e9;
            border-left: 4px solid #4CAF50;
            padding: 10px 15px;
            margin: 20px 0;
            border-radius: 4px;
            font-size: 14px;
        }
        .perf-info strong {
            color: #2E7D32;
        }
        @keyframes pulse {
            0%, 100% { opacity: 1; }
            50% { opacity: 0.5; }
        }
        .loading {
            animation: pulse 1.5s ease-in-out infinite;
        }
    </style>
</head>
<body>
    <div class="container">
        <div style="text-align: center; font-size: 48px; font-weight: bold; color: #4CAF50; margin-bottom: 30px; text-shadow: 2px 2px 4px rgba(0,0,0,0.1);">
            Hello, World!
        </div>
        <h1>Microservices Dashboard</h1>
        <p style="text-align: center; color: #666;">This dashboard aggregates data from multiple microservices</p>

        <div class="perf-info">
            <strong>⚡ Performance Optimizations Active:</strong> Parallel API calls, intelligent caching, and reduced timeouts for faster load times!
        </div>

        <div class="service-box">
            <div class="service-title">⏰ Time Service</div>
            <div class="data-item"><span class="label">Current Time:</span> <span id="current-time">{{ time_data.timestamp }}</span></div>
            <div class="data-item"><span class="label">Service:</span> <span id="time-service-name">{{ time_data.service }}</span></div>
            <div class="data-item"><span class="label">Status:</span> <span id="time-status" style="color: #4CAF50;">●</span> <span id="time-status-text">Live</span></div>
        </div>

        <div class="service-box">
            <div class="service-title">💻 System Info Service</div>
            <div class="data-item"><span class="label">Host Machine:</span> {{ sysinfo_data.hostname }}</div>
            <div class="data-item"><span class="label">Container:</span> {{ sysinfo_data.container_hostname }}</div>
            <div class="data-item"><span class="label">Platform:</span> {{ sysinfo_data.platform }} {{ sysinfo_data.platform_release }}</div>
            <div class="data-item"><span class="label">Architecture:</span> {{ sysinfo_data.architecture }}</div>
            <div class="data-item"><span class="label">Python Version:</span> {{ sysinfo_data.python_version }}</div>
            <div class="data-item"><span class="label">CPU Cores:</span> {{ sysinfo_data.cpu_count }} ({{ sysinfo_data.cpu_count_physical }} physical)</div>
            <div class="data-item"><span class="label">Memory:</span> {{ sysinfo_data.memory_available_gb }} GB available / {{ sysinfo_data.memory_total_gb }} GB total ({{ sysinfo_data.memory_percent }}% used)</div>
            <div class="data-item"><span class="label">Service:</span> {{ sysinfo_data.service }}</div>
        </div>

        <div class="service-box">
            <div class="service-title">
                🌤️ Weather Service
                {% if weather_data.get('cached') %}
                    <span class="cache-badge">CACHED{% if weather_data.get('cache_age_seconds') %} ({{ weather_data.cache_age_seconds }}s old){% endif %}</span>
                {% endif %}
            </div>
            {% if weather_data.get('error') and not weather_data.get('stale') %}
                <div class="data-item" style="color: #d32f2f;"><span class="label">Status:</span> {{ weather_data.message }}</div>
            {% else %}
                {% if weather_data.get('stale') %}
                    <div class="data-item" style="color: #ff9800; font-size: 12px;">⚠️ Using cached data due to API error</div>
                {% endif %}
                <div class="data-item"><span class="label">Location:</span> {{ weather_data.location.city }}, {{ weather_data.location.country }}</div>
                <div class="data-item"><span class="label">Coordinates:</span> {{ weather_data.location.latitude }}, {{ weather_data.location.longitude }}</div>
                <div class="data-item"><span class="label">Condition:</span> {{ weather_data.weather.condition }}</div>
                <div class="data-item"><span class="label">Temperature:</span> {{ weather_data.weather.temperature_c }}°C ({{ weather_data.weather.temperature_f }}°F)</div>
                <div class="data-item"><span class="label">Feels Like:</span> {{ weather_data.weather.feels_like_c }}°C</div>
                <div class="data-item"><span class="label">Humidity:</span> {{ weather_data.weather.humidity }}%</div>
                <div class="data-item"><span class="label">Wind Speed:</span> {{ weather_data.weather.wind_speed_kmph }} km/h</div>
            {% endif %}
        </div>

        <button class="refresh-btn" onclick="location.reload()">Refresh Data</button>
    </div>
    <script>
        // Update time every second
        function updateTime() {
            fetch('/api/time-proxy')
                .then(response => response.json())
                .then(data => {
                    document.getElementById('current-time').textContent = data.timestamp;
                    document.getElementById('time-service-name').textContent = data.service;
                    document.getElementById('time-status').style.color = '#4CAF50';
                    document.getElementById('time-status-text').textContent = 'Live';
                })
                .catch(error => {
                    document.getElementById('current-time').textContent = 'Service unavailable';
                    document.getElementById('time-status').style.color = '#d32f2f';
                    document.getElementById('time-status-text').textContent = 'Offline';
                });
        }

        // Update immediately and then every second
        updateTime();
        setInterval(updateTime, 1000);
    </script>
</body>
</html>
'''

def fetch_service(service_name, url, timeout, default_error):
    """
    Fetch data from a backend microservice with timeout and error handling.

    This helper function is designed to be called in parallel using ThreadPoolExecutor.
    It measures the request duration and records it to Prometheus metrics regardless
    of success or failure. Sanitizes output to prevent XSS attacks.

    Args:
        service_name (str): Name of the service for metrics labeling
        url (str): Full URL of the service endpoint to call
        timeout (int): Request timeout in seconds
        default_error (callable): Function to generate error response if request fails

    Returns:
        tuple: (service_name, response_data) where response_data is either the JSON
               response from the service or the error object from default_error()
    """
    start_time = time.time()
    try:
        # Validate service URL to prevent SSRF
        if not validate_service_url(url):
            logger.error(f'Blocked invalid service URL: {url}')
            return service_name, default_error('Invalid service URL')

        response = requests.get(url, timeout=timeout, headers={'X-API-Key': API_KEY})
        # Record successful request duration
        UPSTREAM_REQUEST_DURATION.labels(service=service_name).observe(time.time() - start_time)

        # Sanitize response data to prevent XSS
        data = response.json()
        sanitized_data = sanitize_output(data)
        return service_name, sanitized_data
    except Exception as e:
        # Record failed request duration (still important for monitoring)
        UPSTREAM_REQUEST_DURATION.labels(service=service_name).observe(time.time() - start_time)
        logger.error(f'Service {service_name} error: {type(e).__name__}')
        # Return generic error message without exposing internal details
        return service_name, default_error('Service temporarily unavailable')

@app.route('/', methods=['GET'])
def dashboard():
    """
    Main dashboard endpoint that aggregates data from all backend services.

    This endpoint calls three backend microservices in parallel to minimize latency.
    Instead of waiting for each service sequentially (which could take 11+ seconds),
    parallel execution reduces total time to the slowest single service (~5 seconds).

    Returns:
        str: Rendered HTML dashboard with aggregated data from all services
    """
    start_time = time.time()

    # Define services to call with their configurations
    # Format: (result_key, service_url, timeout_seconds, error_handler_function)
    # Each service gets a custom error handler that returns appropriate fallback data
    services = [
        ('time', TIME_SERVICE_URL, 3, lambda e: {'service': 'time-service', 'timestamp': f'Error: {str(e)}'}),
        ('sysinfo', SYSINFO_SERVICE_URL, 3, lambda e: {'service': 'system-info-service', 'hostname': f'Error: {str(e)}', 'container_hostname': 'N/A', 'platform': 'N/A'}),
        ('weather', WEATHER_SERVICE_URL, 5, lambda e: {'service': 'weather-service', 'error': str(e), 'message': 'Could not fetch weather data'})
    ]

    # Fetch all services in parallel using ThreadPoolExecutor
    # This creates a thread pool with 3 workers (one per service)
    results = {}
    with ThreadPoolExecutor(max_workers=3) as executor:
        # Submit all service calls simultaneously
        futures = {executor.submit(fetch_service, name, url, timeout, error_handler): name
                   for name, url, timeout, error_handler in services}

        # Collect results as they complete (not necessarily in submission order)
        for future in as_completed(futures):
            service_name, data = future.result()
            results[service_name] = data

    # Record metrics for this dashboard request
    REQUEST_DURATION.labels(endpoint='/', method='GET').observe(time.time() - start_time)
    REQUEST_COUNT.labels(endpoint='/', method='GET', status='200').inc()

    # Render the HTML template with the aggregated data
    return render_template_string(
        HTML_TEMPLATE,
        time_data=results.get('time', {}),
        sysinfo_data=results.get('sysinfo', {}),
        weather_data=results.get('weather', {})
    )

@app.route('/api/aggregate', methods=['GET'])
@require_api_key
@limiter.limit("100 per minute")
def aggregate():
    """
    API endpoint that returns aggregated data from all services in JSON format.

    Similar to the dashboard endpoint but returns raw JSON instead of HTML.
    Useful for programmatic access or integration with other services.
    Requires API key authentication via X-API-Key header.

    Returns:
        Response: JSON object containing data from all backend services
                  Format: {'dashboard': 'aggregator-service', 'time_service': {...}, ...}
    """
    # Define service configurations for JSON API response
    services = [
        ('time_service', TIME_SERVICE_URL, 3, lambda e: {'error': str(e)}),
        ('sysinfo_service', SYSINFO_SERVICE_URL, 3, lambda e: {'error': str(e)}),
        ('weather_service', WEATHER_SERVICE_URL, 5, lambda e: {'error': str(e)})
    ]

    # Initialize results with service identifier
    results = {'dashboard': 'aggregator-service'}

    # Fetch all services in parallel
    with ThreadPoolExecutor(max_workers=3) as executor:
        futures = {executor.submit(fetch_service, name, url, timeout, error_handler): name
                   for name, url, timeout, error_handler in services}

        for future in as_completed(futures):
            service_name, data = future.result()
            results[service_name] = data

    return jsonify(results)

@app.route('/api/time-proxy', methods=['GET'])
def time_proxy():
    """
    Proxy endpoint for the time service with short timeout.

    This endpoint is called by JavaScript on the dashboard page to update
    the time display every second. Uses a short 2-second timeout for
    responsiveness.

    Returns:
        Response: JSON from time service, or error message with 500 status
    """
    try:
        time_response = requests.get(TIME_SERVICE_URL, timeout=2)
        return jsonify(time_response.json())
    except Exception as e:
        return jsonify({'service': 'time-service', 'timestamp': f'Error: {str(e)}'}), 500

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
@limiter.exempt  # Exempt from rate limiting for Prometheus scraping
def metrics():
    """
    Prometheus metrics endpoint.

    Exposes all collected Prometheus metrics in a format that can be scraped
    by Prometheus server for monitoring and alerting.
    Exempt from rate limiting to allow frequent Prometheus scrapes.

    Returns:
        Response: Prometheus-formatted metrics in plain text
    """
    return generate_latest(), 200, {'Content-Type': CONTENT_TYPE_LATEST}

# ============================================================================
# Application Entry Point
# ============================================================================
if __name__ == '__main__':
    # Run Flask development server on all interfaces, port 5000
    # In production, this would be served by a WSGI server like Gunicorn
    app.run(host='0.0.0.0', port=5000)
