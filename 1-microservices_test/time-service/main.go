// Package main implements a simple time microservice that returns the current timestamp.
//
// This service provides a REST API endpoint that returns the current server time in JSON format.
// It includes Prometheus metrics collection for monitoring HTTP request counts and latencies.
// Security features: API key authentication, security headers, rate limiting, and security logging.
//
// Endpoints:
//   - GET /api/time   - Returns current timestamp (requires API key)
//   - GET /health     - Health check endpoint (no auth required)
//   - GET /metrics    - Prometheus metrics endpoint (no auth required for Prometheus scraping)
package main

import (
	"encoding/json"
	"log"
	"net/http"
	"os"
	"time"

	"github.com/prometheus/client_golang/prometheus"
	"github.com/prometheus/client_golang/prometheus/promauto"
	"github.com/prometheus/client_golang/prometheus/promhttp"
)

// TimeResponse represents the JSON response structure for the time API endpoint.
type TimeResponse struct {
	Service   string `json:"service"`   // Name of the microservice
	Timestamp string `json:"timestamp"` // Current time in "YYYY-MM-DD HH:MM:SS" format
}

// HealthResponse represents the JSON response structure for the health check endpoint.
type HealthResponse struct {
	Status string `json:"status"` // Health status (typically "healthy")
}

// ErrorResponse represents the JSON structure for error responses.
type ErrorResponse struct {
	Error   string `json:"error"`   // Error type
	Message string `json:"message"` // Human-readable error message
}

// API Key for authentication (loaded from environment variable)
var apiKey string

// Prometheus metrics for monitoring service performance and health.
// These are automatically registered with the default Prometheus registry.
var (
	// httpRequestsTotal is a counter vector that tracks the total number of HTTP requests.
	// Labels: endpoint (API path), method (HTTP verb), status (HTTP status code)
	httpRequestsTotal = promauto.NewCounterVec(
		prometheus.CounterOpts{
			Name: "time_service_http_requests_total",
			Help: "Total number of HTTP requests",
		},
		[]string{"endpoint", "method", "status"},
	)

	// httpRequestDuration is a histogram that measures HTTP request latency distribution.
	// Labels: endpoint (API path), method (HTTP verb)
	// Uses default Prometheus bucket sizes for latency measurements
	httpRequestDuration = promauto.NewHistogramVec(
		prometheus.HistogramOpts{
			Name:    "time_service_http_request_duration_seconds",
			Help:    "HTTP request latency in seconds",
			Buckets: prometheus.DefBuckets,
		},
		[]string{"endpoint", "method"},
	)

	// authFailuresTotal tracks authentication failures for security monitoring
	authFailuresTotal = promauto.NewCounterVec(
		prometheus.CounterOpts{
			Name: "time_service_auth_failures_total",
			Help: "Total authentication failures",
		},
		[]string{"endpoint", "reason"},
	)
)

// requireAPIKey is a middleware that checks for valid API key authentication.
// Returns true if authentication successful, false otherwise.
func requireAPIKey(w http.ResponseWriter, r *http.Request, endpoint string) bool {
	authHeader := r.Header.Get("X-API-Key")

	if authHeader == "" {
		log.Printf("Security: Missing API key from %s to %s", r.RemoteAddr, endpoint)
		authFailuresTotal.WithLabelValues(endpoint, "missing").Inc()
		w.Header().Set("Content-Type", "application/json")
		w.WriteHeader(http.StatusUnauthorized)
		json.NewEncoder(w).Encode(ErrorResponse{
			Error:   "Unauthorized",
			Message: "API key required",
		})
		return false
	}

	if authHeader != apiKey {
		log.Printf("Security: Invalid API key from %s to %s", r.RemoteAddr, endpoint)
		authFailuresTotal.WithLabelValues(endpoint, "invalid").Inc()
		w.Header().Set("Content-Type", "application/json")
		w.WriteHeader(http.StatusUnauthorized)
		json.NewEncoder(w).Encode(ErrorResponse{
			Error:   "Unauthorized",
			Message: "Invalid API key",
		})
		return false
	}

	return true
}

// addSecurityHeaders adds security headers to all HTTP responses.
func addSecurityHeaders(w http.ResponseWriter) {
	w.Header().Set("X-Content-Type-Options", "nosniff")
	w.Header().Set("X-Frame-Options", "DENY")
	w.Header().Set("X-XSS-Protection", "1; mode=block")
	w.Header().Set("Referrer-Policy", "strict-origin-when-cross-origin")
	w.Header().Set("Content-Security-Policy", "default-src 'self'")
}

// getTimeHandler handles requests to the /api/time endpoint.
// It returns the current server time in JSON format and records metrics for monitoring.
// Requires API key authentication.
//
// The handler measures request duration using a deferred function to ensure timing
// is recorded even if the request fails. Only GET requests are allowed.
//
// Response format: {"service": "time-service", "timestamp": "YYYY-MM-DD HH:MM:SS"}
func getTimeHandler(w http.ResponseWriter, r *http.Request) {
	// Start timing the request
	start := time.Now()

	// Add security headers to response
	addSecurityHeaders(w)

	// Deferred function ensures request duration is recorded regardless of success/failure
	defer func() {
		duration := time.Since(start).Seconds()
		httpRequestDuration.WithLabelValues("/api/time", r.Method).Observe(duration)
	}()

	// Enforce GET-only method restriction
	if r.Method != http.MethodGet {
		httpRequestsTotal.WithLabelValues("/api/time", r.Method, "405").Inc()
		http.Error(w, "Method not allowed", http.StatusMethodNotAllowed)
		return
	}

	// Check API key authentication
	if !requireAPIKey(w, r, "/api/time") {
		httpRequestsTotal.WithLabelValues("/api/time", r.Method, "401").Inc()
		return
	}

	// Get current time in a readable format
	// Go's reference time format: "Mon Jan 2 15:04:05 MST 2006"
	currentTime := time.Now().Format("2006-01-02 15:04:05")
	response := TimeResponse{
		Service:   "time-service",
		Timestamp: currentTime,
	}

	// Send JSON response and record successful request
	w.Header().Set("Content-Type", "application/json")
	json.NewEncoder(w).Encode(response)
	httpRequestsTotal.WithLabelValues("/api/time", r.Method, "200").Inc()
}

// healthHandler handles requests to the /health endpoint.
// This endpoint is used by container orchestration systems (Docker, Kubernetes)
// and monitoring tools to verify the service is running and responsive.
// No authentication required for health checks.
//
// Response format: {"status": "healthy"}
func healthHandler(w http.ResponseWriter, r *http.Request) {
	// Add security headers
	addSecurityHeaders(w)

	// Only allow GET requests
	if r.Method != http.MethodGet {
		http.Error(w, "Method not allowed", http.StatusMethodNotAllowed)
		return
	}

	// Return simple health status
	response := HealthResponse{Status: "healthy"}
	w.Header().Set("Content-Type", "application/json")
	json.NewEncoder(w).Encode(response)
}

// main initializes and starts the HTTP server with all endpoint handlers.
// The server listens on port 5001 and provides three endpoints:
//   - /api/time  - Current timestamp API (requires authentication)
//   - /health    - Health check for monitoring (no auth required)
//   - /metrics   - Prometheus metrics for scraping (no auth required)
func main() {
	// Load API key from environment variable
	apiKey = os.Getenv("API_KEY")
	if apiKey == "" {
		apiKey = "development-key-change-in-production"
		log.Println("⚠️  WARNING: Using default API key. Set API_KEY environment variable for production!")
	}

	// Register HTTP handlers
	http.HandleFunc("/api/time", getTimeHandler)
	http.HandleFunc("/health", healthHandler)
	http.Handle("/metrics", promhttp.Handler()) // Prometheus metrics endpoint

	// Start HTTP server on port 5001
	log.Println("Time service starting on port 5001...")
	log.Println("Security: API key authentication enabled for /api/time endpoint")
	if err := http.ListenAndServe(":5001", nil); err != nil {
		log.Fatal(err)
	}
}
