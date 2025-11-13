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

type TimeResponse struct {
	Service   string `json:"service"`
	Timestamp string `json:"timestamp"`
}

type HealthResponse struct {
	Status string `json:"status"`
}

var (
	httpRequestsTotal = promauto.NewCounterVec(
		prometheus.CounterOpts{
			Name: "time_service_http_requests_total",
			Help: "Total number of HTTP requests",
		},
		[]string{"endpoint", "method", "status"},
	)

	httpRequestDuration = promauto.NewHistogramVec(
		prometheus.HistogramOpts{
			Name:    "time_service_http_request_duration_seconds",
			Help:    "HTTP request latency in seconds",
			Buckets: prometheus.DefBuckets,
		},
		[]string{"endpoint", "method"},
	)
)

func getTimeHandler(w http.ResponseWriter, r *http.Request) {
	start := time.Now()
	defer func() {
		duration := time.Since(start).Seconds()
		httpRequestDuration.WithLabelValues("/api/time", r.Method).Observe(duration)
	}()

	if r.Method != http.MethodGet {
		httpRequestsTotal.WithLabelValues("/api/time", r.Method, "405").Inc()
		http.Error(w, "Method not allowed", http.StatusMethodNotAllowed)
		return
	}

	currentTime := time.Now().Format("2006-01-02 15:04:05")
	response := TimeResponse{
		Service:   "time-service",
		Timestamp: currentTime,
	}

	w.Header().Set("Content-Type", "application/json")
	json.NewEncoder(w).Encode(response)
	httpRequestsTotal.WithLabelValues("/api/time", r.Method, "200").Inc()
}

func healthHandler(w http.ResponseWriter, r *http.Request) {
	if r.Method != http.MethodGet {
		http.Error(w, "Method not allowed", http.StatusMethodNotAllowed)
		return
	}

	response := HealthResponse{Status: "healthy"}
	w.Header().Set("Content-Type", "application/json")
	json.NewEncoder(w).Encode(response)
}

func main() {
	http.HandleFunc("/api/time", getTimeHandler)
	http.HandleFunc("/health", healthHandler)
	http.Handle("/metrics", promhttp.Handler())

	log.Println("Time service starting on port 5001...")
	if err := http.ListenAndServe(":5001", nil); err != nil {
		log.Fatal(err)
	}
}
