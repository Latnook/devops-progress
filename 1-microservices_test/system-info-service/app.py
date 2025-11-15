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

from flask import Flask, jsonify
import socket
import platform
import os
import psutil
from prometheus_client import Counter, Histogram, generate_latest, CONTENT_TYPE_LATEST
import time

app = Flask(__name__)

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

@app.route('/api/sysinfo', methods=['GET'])
def get_system_info():
    """
    Collects and returns comprehensive system information.

    This endpoint gathers information about both the host machine and the
    container it's running in. It uses environment variables to distinguish
    between the host hostname and container hostname when running in Docker.

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
    hostname = os.environ.get('HOST_HOSTNAME', socket.gethostname())
    container_hostname = socket.gethostname()

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
