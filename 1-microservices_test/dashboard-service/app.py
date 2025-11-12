from flask import Flask, jsonify, render_template_string
import requests
from concurrent.futures import ThreadPoolExecutor, as_completed

app = Flask(__name__)

TIME_SERVICE_URL = 'http://time-service:5001/api/time'
SYSINFO_SERVICE_URL = 'http://system-info-service:5002/api/sysinfo'
WEATHER_SERVICE_URL = 'http://weather-service:5003/api/weather'

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
    """Helper function to fetch data from a service"""
    try:
        response = requests.get(url, timeout=timeout)
        return service_name, response.json()
    except Exception as e:
        return service_name, default_error(e)

@app.route('/', methods=['GET'])
def dashboard():
    # Define services to call with their configurations
    services = [
        ('time', TIME_SERVICE_URL, 3, lambda e: {'service': 'time-service', 'timestamp': f'Error: {str(e)}'}),
        ('sysinfo', SYSINFO_SERVICE_URL, 3, lambda e: {'service': 'system-info-service', 'hostname': f'Error: {str(e)}', 'container_hostname': 'N/A', 'platform': 'N/A'}),
        ('weather', WEATHER_SERVICE_URL, 5, lambda e: {'service': 'weather-service', 'error': str(e), 'message': 'Could not fetch weather data'})
    ]

    # Fetch all services in parallel
    results = {}
    with ThreadPoolExecutor(max_workers=3) as executor:
        futures = {executor.submit(fetch_service, name, url, timeout, error_handler): name
                   for name, url, timeout, error_handler in services}

        for future in as_completed(futures):
            service_name, data = future.result()
            results[service_name] = data

    return render_template_string(
        HTML_TEMPLATE,
        time_data=results.get('time', {}),
        sysinfo_data=results.get('sysinfo', {}),
        weather_data=results.get('weather', {})
    )

@app.route('/api/aggregate', methods=['GET'])
def aggregate():
    services = [
        ('time_service', TIME_SERVICE_URL, 3, lambda e: {'error': str(e)}),
        ('sysinfo_service', SYSINFO_SERVICE_URL, 3, lambda e: {'error': str(e)}),
        ('weather_service', WEATHER_SERVICE_URL, 5, lambda e: {'error': str(e)})
    ]

    results = {'dashboard': 'aggregator-service'}
    with ThreadPoolExecutor(max_workers=3) as executor:
        futures = {executor.submit(fetch_service, name, url, timeout, error_handler): name
                   for name, url, timeout, error_handler in services}

        for future in as_completed(futures):
            service_name, data = future.result()
            results[service_name] = data

    return jsonify(results)

@app.route('/api/time-proxy', methods=['GET'])
def time_proxy():
    try:
        time_response = requests.get(TIME_SERVICE_URL, timeout=2)
        return jsonify(time_response.json())
    except Exception as e:
        return jsonify({'service': 'time-service', 'timestamp': f'Error: {str(e)}'}), 500

@app.route('/health', methods=['GET'])
def health():
    return jsonify({'status': 'healthy'})

if __name__ == '__main__':
    app.run(host='0.0.0.0', port=5000)
