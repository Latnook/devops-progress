"""
Weather Service - Python/Flask Implementation

This microservice fetches weather data for Haifa, Israel from the wttr.in API
and provides it through a REST endpoint. It implements intelligent caching with
a stale-while-revalidate strategy to improve performance and handle API failures.

Features:
- 10-minute cache duration for weather data to reduce API calls
- Fallback to stale cache during API errors (graceful degradation)
- Uses certifi for reliable SSL certificate verification
- Simple and lightweight Python implementation

This is a Python alternative to the Node.js weather service (server.js).
"""

from flask import Flask, jsonify
import requests
import certifi
import socket
from datetime import datetime, timedelta

app = Flask(__name__)

# ============================================================================
# Cache Configuration
# ============================================================================
# In-memory cache for weather data to reduce API calls and improve performance.
# The cache stores weather data with a timestamp and validates based on age.
weather_cache = {
    'data': None,  # Cached weather data dictionary
    'timestamp': None,  # datetime object when data was cached
    'cache_duration_minutes': 10  # Cache validity duration (10 minutes)
}

def is_cache_valid():
    """
    Check if cached weather data is still valid based on age.

    The cache is considered valid if both data and timestamp exist, and the
    age is less than the configured cache duration (10 minutes by default).

    Returns:
        bool: True if cache is valid and can be used, False otherwise
    """
    if weather_cache['data'] is None or weather_cache['timestamp'] is None:
        return False

    cache_age = datetime.now() - weather_cache['timestamp']
    return cache_age < timedelta(minutes=weather_cache['cache_duration_minutes'])

@app.route('/api/weather', methods=['GET'])
def get_weather():
    """
    Weather data endpoint with intelligent caching and error handling.

    Returns current weather data for Haifa, Israel. Implements a cache-first
    strategy with stale-while-revalidate fallback:
    1. If cache is valid (< 10 minutes old), return cached data immediately
    2. If cache is invalid/missing, fetch fresh data from wttr.in API
    3. If API call fails and stale cache exists, return stale data with warning
    4. If API call fails and no cache exists, return error

    Uses certifi for SSL certificate verification to handle systems with
    custom CA certificates or outdated certificate bundles.

    Returns:
        Response: JSON with weather data (fresh, cached, or stale), or error
                  with 500 status if API fails with no cache available
    """
    try:
        # Return cached data if still valid (cache hit)
        if is_cache_valid():
            cached_response = weather_cache['data'].copy()
            cached_response['cached'] = True
            cached_response['cache_age_seconds'] = int((datetime.now() - weather_cache['timestamp']).total_seconds())
            return jsonify(cached_response)

        # Cache miss - need to fetch fresh data
        # Hardcoded location for Haifa, Israel
        # In a production system, this could be configurable or accept query parameters
        city = 'Haifa'
        country = 'Israel'
        latitude = 32.7940
        longitude = 34.9896

        # Fetch weather data from wttr.in API
        # format=j1 returns JSON format with comprehensive weather data
        # certifi.where() provides path to trusted CA bundle for SSL verification
        weather_url = f'https://wttr.in/Haifa,Israel?format=j1'
        weather_response = requests.get(weather_url, timeout=5, verify=certifi.where())
        weather_data = weather_response.json()

        # Extract current weather condition from API response
        # Use .get() with defaults to handle missing data gracefully
        current_condition = weather_data.get('current_condition', [{}])[0]

        # Build response object with location and weather data
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

        # Update cache with fresh data for future requests
        weather_cache['data'] = response_data.copy()
        weather_cache['timestamp'] = datetime.now()

        return jsonify(response_data)
    except Exception as e:
        # Error handling: Implement stale-while-revalidate pattern
        # If we have cached data (even if expired), return it during errors
        # This provides better UX than showing an error when we have some data
        if weather_cache['data'] is not None:
            stale_response = weather_cache['data'].copy()
            stale_response['cached'] = True
            stale_response['stale'] = True
            stale_response['error'] = f'Using stale cache due to error: {str(e)}'
            return jsonify(stale_response)

        # No cache available - return error response
        return jsonify({
            'service': 'weather-service',
            'error': str(e),
            'message': 'Could not fetch weather data'
        }), 500

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

# ============================================================================
# Application Entry Point
# ============================================================================
if __name__ == '__main__':
    # Run Flask development server on all interfaces, port 5003
    # In production, this would be served by a WSGI server like Gunicorn
    app.run(host='0.0.0.0', port=5003)
