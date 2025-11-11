from flask import Flask, jsonify, render_template_string
import requests

app = Flask(__name__)

TIME_SERVICE_URL = 'http://time-service:5001/api/time'
SYSINFO_SERVICE_URL = 'http://system-info-service:5002/api/sysinfo'

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
            <div class="data-item"><span class="label">Platform:</span> {{ sysinfo_data.platform }}</div>
            <div class="data-item"><span class="label">Service:</span> {{ sysinfo_data.service }}</div>
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

    return render_template_string(HTML_TEMPLATE, time_data=time_data, sysinfo_data=sysinfo_data)

@app.route('/api/aggregate', methods=['GET'])
def aggregate():
    try:
        # Call both services
        time_response = requests.get(TIME_SERVICE_URL, timeout=5)
        sysinfo_response = requests.get(SYSINFO_SERVICE_URL, timeout=5)

        return jsonify({
            'dashboard': 'aggregator-service',
            'time_service': time_response.json(),
            'sysinfo_service': sysinfo_response.json()
        })
    except Exception as e:
        return jsonify({'error': str(e)}), 500

@app.route('/health', methods=['GET'])
def health():
    return jsonify({'status': 'healthy'})

if __name__ == '__main__':
    app.run(host='0.0.0.0', port=5000)
