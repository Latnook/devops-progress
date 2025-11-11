from flask import Flask, jsonify
import socket
import platform
import os
import psutil

app = Flask(__name__)

@app.route('/api/sysinfo', methods=['GET'])
def get_system_info():
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

    return jsonify(system_info)

@app.route('/health', methods=['GET'])
def health():
    return jsonify({'status': 'healthy'})

if __name__ == '__main__':
    app.run(host='0.0.0.0', port=5002)
