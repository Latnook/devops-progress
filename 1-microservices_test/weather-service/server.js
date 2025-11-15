/**
 * Weather Service - Node.js/Express Implementation
 *
 * This microservice fetches weather data for Haifa, Israel from the wttr.in API
 * and provides it through a REST endpoint. It implements intelligent caching with
 * stale-while-revalidate strategy to improve performance and handle API failures.
 *
 * Features:
 * - 10-minute cache duration for weather data
 * - Fallback to stale cache during API errors
 * - Prometheus metrics for monitoring cache hit rate and request latency
 * - Health check endpoint for container orchestration
 *
 * @module weather-service
 */

const express = require('express');
const axios = require('axios');
const promClient = require('prom-client');

const app = express();
const PORT = 5003;

// ============================================================================
// Prometheus Metrics Setup
// ============================================================================
// Create a custom registry for this service's metrics
const register = new promClient.Registry();

// Automatically collect default Node.js metrics (memory, CPU, etc.)
promClient.collectDefaultMetrics({ register });

/**
 * Counter for total HTTP requests to this service.
 * Labels: endpoint (API path), method (HTTP verb), status (HTTP status code)
 */
const httpRequestsTotal = new promClient.Counter({
    name: 'weather_service_http_requests_total',
    help: 'Total HTTP requests',
    labelNames: ['endpoint', 'method', 'status'],
    registers: [register]
});

/**
 * Histogram for measuring HTTP request latency distribution.
 * Labels: endpoint (API path), method (HTTP verb)
 */
const httpRequestDuration = new promClient.Histogram({
    name: 'weather_service_http_request_duration_seconds',
    help: 'HTTP request latency',
    labelNames: ['endpoint', 'method'],
    registers: [register]
});

/**
 * Counter for cache hits - incremented when valid cached data is returned.
 * Used to monitor cache effectiveness.
 */
const cacheHits = new promClient.Counter({
    name: 'weather_service_cache_hits_total',
    help: 'Total weather cache hits',
    registers: [register]
});

/**
 * Counter for cache misses - incremented when fresh API call is needed.
 * Used to monitor cache effectiveness.
 */
const cacheMisses = new promClient.Counter({
    name: 'weather_service_cache_misses_total',
    help: 'Total weather cache misses',
    registers: [register]
});

// ============================================================================
// Cache Configuration
// ============================================================================
/**
 * In-memory cache for weather data to reduce API calls and improve performance.
 * The cache stores weather data with a timestamp and validates based on age.
 *
 * @type {Object}
 * @property {Object|null} data - Cached weather data object
 * @property {number|null} timestamp - Timestamp (ms) when data was cached
 * @property {number} cacheDurationMinutes - Cache validity duration in minutes
 */
const weatherCache = {
    data: null,
    timestamp: null,
    cacheDurationMinutes: 10
};

/**
 * Checks if the cached weather data is still valid based on age.
 *
 * The cache is considered valid if:
 * 1. Both data and timestamp exist
 * 2. The age is less than the configured cache duration
 *
 * @returns {boolean} True if cache is valid and can be used, false otherwise
 */
function isCacheValid() {
    if (!weatherCache.data || !weatherCache.timestamp) {
        return false;
    }

    const cacheAge = Date.now() - weatherCache.timestamp;
    const maxAge = weatherCache.cacheDurationMinutes * 60 * 1000; // Convert to milliseconds
    return cacheAge < maxAge;
}

/**
 * Calculates the age of the cached data in seconds.
 *
 * @returns {number} Age of cached data in seconds, or 0 if no cache exists
 */
function getCacheAgeSeconds() {
    if (!weatherCache.timestamp) return 0;
    return Math.floor((Date.now() - weatherCache.timestamp) / 1000);
}

// ============================================================================
// API Endpoints
// ============================================================================

/**
 * GET /api/weather - Weather data endpoint with intelligent caching
 *
 * Returns current weather data for Haifa, Israel. Implements a cache-first
 * strategy with stale-while-revalidate fallback:
 * 1. If cache is valid (< 10 minutes old), return cached data immediately
 * 2. If cache is invalid/missing, fetch fresh data from wttr.in API
 * 3. If API call fails and stale cache exists, return stale data with warning
 * 4. If API call fails and no cache exists, return error
 *
 * @async
 * @route GET /api/weather
 * @returns {Object} Weather data with location and current conditions
 * @returns {Object} 200 - Weather data (fresh, cached, or stale)
 * @returns {Object} 500 - Error message if API fails with no cache available
 */
app.get('/api/weather', async (req, res) => {
    const start = Date.now();

    try {
        // Return cached data if still valid (cache hit)
        if (isCacheValid()) {
            cacheHits.inc();
            const cachedResponse = {
                ...weatherCache.data,
                cached: true,
                cache_age_seconds: getCacheAgeSeconds()
            };
            httpRequestDuration.labels('/api/weather', 'GET').observe((Date.now() - start) / 1000);
            httpRequestsTotal.labels('/api/weather', 'GET', '200').inc();
            return res.json(cachedResponse);
        }

        // Cache miss - need to fetch fresh data
        cacheMisses.inc();

        // Hardcoded location for Haifa, Israel
        // In a production system, this could be configurable or accept query parameters
        const city = 'Haifa';
        const country = 'Israel';
        const latitude = 32.7940;
        const longitude = 34.9896;

        // Fetch weather data from wttr.in API for Haifa
        // wttr.in provides free weather data in JSON format (format=j1)
        const weatherUrl = 'https://wttr.in/Haifa,Israel?format=j1';
        const weatherResponse = await axios.get(weatherUrl, { timeout: 5000 });
        const weatherData = weatherResponse.data;

        // Extract current weather condition from API response
        // Use optional chaining and fallback to handle missing data gracefully
        const currentCondition = weatherData.current_condition?.[0] || {};

        // Build response object with location and weather data
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

        // Update cache with fresh data
        weatherCache.data = { ...responseData };
        weatherCache.timestamp = Date.now();

        // Record metrics for successful request
        httpRequestDuration.labels('/api/weather', 'GET').observe((Date.now() - start) / 1000);
        httpRequestsTotal.labels('/api/weather', 'GET', '200').inc();

        res.json(responseData);
    } catch (error) {
        // Error handling: Implement stale-while-revalidate pattern
        // If we have cached data (even if expired), return it during errors
        // This provides better UX than showing an error when we have some data
        if (weatherCache.data) {
            const staleResponse = {
                ...weatherCache.data,
                cached: true,
                stale: true,
                error: `Using stale cache due to error: ${error.message}`
            };
            httpRequestDuration.labels('/api/weather', 'GET').observe((Date.now() - start) / 1000);
            httpRequestsTotal.labels('/api/weather', 'GET', '200').inc();
            return res.json(staleResponse);
        }

        // No cache available - return error response
        httpRequestDuration.labels('/api/weather', 'GET').observe((Date.now() - start) / 1000);
        httpRequestsTotal.labels('/api/weather', 'GET', '500').inc();

        res.status(500).json({
            service: 'weather-service',
            error: error.message,
            message: 'Could not fetch weather data'
        });
    }
});

/**
 * GET /health - Health check endpoint
 *
 * Used by container orchestration systems (Docker, Kubernetes) and monitoring
 * tools to verify the service is running and responsive.
 *
 * @route GET /health
 * @returns {Object} 200 - Health status object
 */
app.get('/health', (req, res) => {
    res.json({ status: 'healthy' });
});

/**
 * GET /metrics - Prometheus metrics endpoint
 *
 * Exposes all collected Prometheus metrics in a format that can be scraped
 * by Prometheus server for monitoring and alerting. Includes default Node.js
 * metrics plus custom application metrics (request counts, cache hits, etc.).
 *
 * @async
 * @route GET /metrics
 * @returns {string} 200 - Prometheus-formatted metrics in plain text
 */
app.get('/metrics', async (req, res) => {
    res.set('Content-Type', register.contentType);
    res.end(await register.metrics());
});

// ============================================================================
// Server Initialization
// ============================================================================
/**
 * Start the Express server on all network interfaces (0.0.0.0) at port 5003.
 * In production, this would typically run behind a reverse proxy like Nginx.
 */
app.listen(PORT, '0.0.0.0', () => {
    console.log(`Weather service listening on port ${PORT}...`);
});
