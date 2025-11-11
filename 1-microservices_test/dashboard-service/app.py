from flask import Flask, jsonify, render_template_string
import requests

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
    </style>
</head>
<body>
    <div class="container">
        <div style="text-align: center; font-size: 48px; font-weight: bold; color: #4CAF50; margin-bottom: 30px; text-shadow: 2px 2px 4px rgba(0,0,0,0.1);">
            Hello, World!
        </div>
        <h1>Microservices Dashboard</h1>
        <p style="text-align: center; color: #666;">This dashboard aggregates data from multiple microservices</p>

        <div class="service-box">
            <div class="service-title">⏰ Time Service</div>
            <div class="data-item"><span class="label">Current Time:</span> {{ time_data.timestamp }}</div>
            <div class="data-item"><span class="label">Service:</span> {{ time_data.service }}</div>
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
            <div class="service-title">🌤️ Weather Service</div>
            {% if weather_data.get('error') %}
                <div class="data-item" style="color: #d32f2f;"><span class="label">Status:</span> {{ weather_data.message }}</div>
            {% else %}
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
</body>
</html>
'''

@app.route('/', methods=['GET'])
def dashboard():
    try:
        # Call time service
        time_response = requests.get(TIME_SERVICE_URL, timeout=5)
        time_data = time_response.json()
    except Exception as e:
        time_data = {'service': 'time-service', 'timestamp': f'Error: {str(e)}'}

    try:
        # Call system info service
        sysinfo_response = requests.get(SYSINFO_SERVICE_URL, timeout=5)
        sysinfo_data = sysinfo_response.json()
    except Exception as e:
        sysinfo_data = {'service': 'system-info-service', 'hostname': f'Error: {str(e)}', 'container_hostname': 'N/A', 'platform': 'N/A'}

    try:
        # Call weather service
        weather_response = requests.get(WEATHER_SERVICE_URL, timeout=10)
        weather_data = weather_response.json()
    except Exception as e:
        weather_data = {'service': 'weather-service', 'error': str(e), 'message': 'Could not fetch weather data'}

    return render_template_string(HTML_TEMPLATE, time_data=time_data, sysinfo_data=sysinfo_data, weather_data=weather_data)

@app.route('/api/aggregate', methods=['GET'])
def aggregate():
    try:
        # Call all services
        time_response = requests.get(TIME_SERVICE_URL, timeout=5)
        sysinfo_response = requests.get(SYSINFO_SERVICE_URL, timeout=5)
        weather_response = requests.get(WEATHER_SERVICE_URL, timeout=10)

        return jsonify({
            'dashboard': 'aggregator-service',
            'time_service': time_response.json(),
            'sysinfo_service': sysinfo_response.json(),
            'weather_service': weather_response.json()
        })
    except Exception as e:
        return jsonify({'error': str(e)}), 500

@app.route('/health', methods=['GET'])
def health():
    return jsonify({'status': 'healthy'})

if __name__ == '__main__':
    app.run(host='0.0.0.0', port=5000)
