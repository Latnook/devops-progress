from flask import Flask, jsonify
import requests
import socket
from datetime import datetime, timedelta

app = Flask(__name__)

# Simple in-memory cache
weather_cache = {
    'data': None,
    'timestamp': None,
    'cache_duration_minutes': 10  # Cache for 10 minutes
}

def is_cache_valid():
    """Check if cached data is still valid"""
    if weather_cache['data'] is None or weather_cache['timestamp'] is None:
        return False

    cache_age = datetime.now() - weather_cache['timestamp']
    return cache_age < timedelta(minutes=weather_cache['cache_duration_minutes'])

@app.route('/api/weather', methods=['GET'])
def get_weather():
    try:
        # Return cached data if still valid
        if is_cache_valid():
            cached_response = weather_cache['data'].copy()
            cached_response['cached'] = True
            cached_response['cache_age_seconds'] = int((datetime.now() - weather_cache['timestamp']).total_seconds())
            return jsonify(cached_response)

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

        response_data = {
            'service': 'weather-service',
            'cached': False,
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
        }

        # Update cache
        weather_cache['data'] = response_data.copy()
        weather_cache['timestamp'] = datetime.now()

        return jsonify(response_data)
    except Exception as e:
        # If we have cached data, return it even if expired during error
        if weather_cache['data'] is not None:
            stale_response = weather_cache['data'].copy()
            stale_response['cached'] = True
            stale_response['stale'] = True
            stale_response['error'] = f'Using stale cache due to error: {str(e)}'
            return jsonify(stale_response)

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
