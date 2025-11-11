from flask import Flask, jsonify
import requests
import socket

app = Flask(__name__)

@app.route('/api/weather', methods=['GET'])
def get_weather():
    try:
        # Hardcoded location for Haifa, Israel
        city = 'Haifa'
        country = 'Israel'
        latitude = 32.7940
        longitude = 34.9896

        # Get weather data from wttr.in API for Haifa
        weather_url = f'https://wttr.in/Haifa,Israel?format=j1'
        weather_response = requests.get(weather_url, timeout=5)
        weather_data = weather_response.json()

        # Extract relevant weather information
        current_condition = weather_data.get('current_condition', [{}])[0]

        return jsonify({
            'service': 'weather-service',
            'location': {
                'city': city,
                'country': country,
                'latitude': latitude,
                'longitude': longitude
            },
            'weather': {
                'temperature_c': current_condition.get('temp_C', 'N/A'),
                'temperature_f': current_condition.get('temp_F', 'N/A'),
                'condition': current_condition.get('weatherDesc', [{}])[0].get('value', 'N/A'),
                'humidity': current_condition.get('humidity', 'N/A'),
                'wind_speed_kmph': current_condition.get('windspeedKmph', 'N/A'),
                'feels_like_c': current_condition.get('FeelsLikeC', 'N/A')
            }
        })
    except Exception as e:
        return jsonify({
            'service': 'weather-service',
            'error': str(e),
            'message': 'Could not fetch weather data'
        }), 500

@app.route('/health', methods=['GET'])
def health():
    return jsonify({'status': 'healthy'})

if __name__ == '__main__':
    app.run(host='0.0.0.0', port=5003)
