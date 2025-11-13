const express = require('express');
const axios = require('axios');

const app = express();
const PORT = 5003;

// Simple in-memory cache
const weatherCache = {
    data: null,
    timestamp: null,
    cacheDurationMinutes: 10
};

function isCacheValid() {
    if (!weatherCache.data || !weatherCache.timestamp) {
        return false;
    }

    const cacheAge = Date.now() - weatherCache.timestamp;
    const maxAge = weatherCache.cacheDurationMinutes * 60 * 1000; // Convert to milliseconds
    return cacheAge < maxAge;
}

function getCacheAgeSeconds() {
    if (!weatherCache.timestamp) return 0;
    return Math.floor((Date.now() - weatherCache.timestamp) / 1000);
}

app.get('/api/weather', async (req, res) => {
    try {
        // Return cached data if still valid
        if (isCacheValid()) {
            const cachedResponse = {
                ...weatherCache.data,
                cached: true,
                cache_age_seconds: getCacheAgeSeconds()
            };
            return res.json(cachedResponse);
        }

        // Hardcoded location for Haifa, Israel
        const city = 'Haifa';
        const country = 'Israel';
        const latitude = 32.7940;
        const longitude = 34.9896;

        // Get weather data from wttr.in API for Haifa
        const weatherUrl = 'https://wttr.in/Haifa,Israel?format=j1';
        const weatherResponse = await axios.get(weatherUrl, { timeout: 5000 });
        const weatherData = weatherResponse.data;

        // Extract relevant weather information
        const currentCondition = weatherData.current_condition?.[0] || {};

        const responseData = {
            service: 'weather-service',
            cached: false,
            location: {
                city,
                country,
                latitude,
                longitude
            },
            weather: {
                temperature_c: currentCondition.temp_C || 'N/A',
                temperature_f: currentCondition.temp_F || 'N/A',
                condition: currentCondition.weatherDesc?.[0]?.value || 'N/A',
                humidity: currentCondition.humidity || 'N/A',
                wind_speed_kmph: currentCondition.windspeedKmph || 'N/A',
                feels_like_c: currentCondition.FeelsLikeC || 'N/A'
            }
        };

        // Update cache
        weatherCache.data = { ...responseData };
        weatherCache.timestamp = Date.now();

        res.json(responseData);
    } catch (error) {
        // If we have cached data, return it even if expired during error
        if (weatherCache.data) {
            const staleResponse = {
                ...weatherCache.data,
                cached: true,
                stale: true,
                error: `Using stale cache due to error: ${error.message}`
            };
            return res.json(staleResponse);
        }

        res.status(500).json({
            service: 'weather-service',
            error: error.message,
            message: 'Could not fetch weather data'
        });
    }
});

app.get('/health', (req, res) => {
    res.json({ status: 'healthy' });
});

app.listen(PORT, '0.0.0.0', () => {
    console.log(`Weather service listening on port ${PORT}...`);
});
