from flask import Flask, jsonify
import socket
import platform
import os
import psutil
from prometheus_client import Counter, Histogram, generate_latest, CONTENT_TYPE_LATEST
import time

app = Flask(__name__)

# Prometheus metrics
REQUEST_COUNT = Counter(
    'system_info_service_http_requests_total',
    'Total HTTP requests',
    ['endpoint', 'method', 'status']
)

REQUEST_DURATION = Histogram(
    'system_info_service_http_request_duration_seconds',
    'HTTP request latency',
    ['endpoint', 'method']
)

@app.route('/api/sysinfo', methods=['GET'])
def get_system_info():
    start_time = time.time()

    # Get host hostname from environment variable, or fall back to container hostname
    hostname = os.environ.get('HOST_HOSTNAME', socket.gethostname())
    container_hostname = socket.gethostname()

    # Get detailed system information
    system_info = {
        'service': 'system-info-service',
        'hostname': hostname,
        'container_hostname': container_hostname,
        'platform': platform.system(),
        'platform_release': platform.release(),
        'platform_version': platform.version(),
        'architecture': platform.machine(),
        'processor': platform.processor() or 'Unknown',
        'python_version': platform.python_version(),
        'cpu_count': psutil.cpu_count(logical=True),
        'cpu_count_physical': psutil.cpu_count(logical=False),
        'memory_total_gb': round(psutil.virtual_memory().total / (1024**3), 2),
        'memory_available_gb': round(psutil.virtual_memory().available / (1024**3), 2),
        'memory_percent': psutil.virtual_memory().percent
    }

    # Record metrics
    duration = time.time() - start_time
    REQUEST_DURATION.labels(endpoint='/api/sysinfo', method='GET').observe(duration)
    REQUEST_COUNT.labels(endpoint='/api/sysinfo', method='GET', status='200').inc()

    return jsonify(system_info)

@app.route('/health', methods=['GET'])
def health():
    return jsonify({'status': 'healthy'})

@app.route('/metrics', methods=['GET'])
def metrics():
    return generate_latest(), 200, {'Content-Type': CONTENT_TYPE_LATEST}

if __name__ == '__main__':
    app.run(host='0.0.0.0', port=5002)
