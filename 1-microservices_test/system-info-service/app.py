from flask import Flask, jsonify
import socket
import platform
import os

app = Flask(__name__)

@app.route('/api/sysinfo', methods=['GET'])
def get_system_info():
    # Get host hostname from environment variable, or fall back to container hostname
    hostname = os.environ.get('HOST_HOSTNAME', socket.gethostname())
    container_hostname = socket.gethostname()
    system = platform.system()
    return jsonify({
        'service': 'system-info-service',
        'hostname': hostname,
        'container_hostname': container_hostname,
        'platform': system
    })

@app.route('/health', methods=['GET'])
def health():
    return jsonify({'status': 'healthy'})

if __name__ == '__main__':
    app.run(host='0.0.0.0', port=5002)
