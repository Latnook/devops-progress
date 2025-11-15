// Package main implements a simple time microservice that returns the current timestamp.
//
// This service provides a REST API endpoint that returns the current server time in JSON format.
// It includes Prometheus metrics collection for monitoring HTTP request counts and latencies.
//
// Endpoints:
//   - GET /api/time   - Returns current timestamp
//   - GET /health     - Health check endpoint
//   - GET /metrics    - Prometheus metrics endpoint
package main

import (
	"encoding/json"
	"log"
	"net/http"
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
)

// getTimeHandler handles requests to the /api/time endpoint.
// It returns the current server time in JSON format and records metrics for monitoring.
//
// The handler measures request duration using a deferred function to ensure timing
// is recorded even if the request fails. Only GET requests are allowed.
//
// Response format: {"service": "time-service", "timestamp": "YYYY-MM-DD HH:MM:SS"}
func getTimeHandler(w http.ResponseWriter, r *http.Request) {
	// Start timing the request
	start := time.Now()

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
//
// Response format: {"status": "healthy"}
func healthHandler(w http.ResponseWriter, r *http.Request) {
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
//   - /api/time  - Current timestamp API
//   - /health    - Health check for monitoring
//   - /metrics   - Prometheus metrics for scraping
func main() {
	// Register HTTP handlers
	http.HandleFunc("/api/time", getTimeHandler)
	http.HandleFunc("/health", healthHandler)
	http.Handle("/metrics", promhttp.Handler()) // Prometheus metrics endpoint

	// Start HTTP server on port 5001
	log.Println("Time service starting on port 5001...")
	if err := http.ListenAndServe(":5001", nil); err != nil {
		log.Fatal(err)
	}
}
