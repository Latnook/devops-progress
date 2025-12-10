# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

This is a DevOps learning repository documenting hands-on implementations of various DevOps concepts and technologies. The main project is a **polyglot microservices architecture** demonstrating containerization, service-to-service communication, and production monitoring patterns.

## Architecture

The microservices system (`1-microservices_test/`) consists of:

1. **Application Layer** - 4 microservices written in different languages:
   - **Time Service** (Go) - Fast compiled service at `time-service:5001`
   - **System Info Service** (Python) - System metrics using psutil at `system-info-service:5002`
   - **Weather Service** (Node.js) - Async external API integration at `weather-service:5003`
   - **Dashboard Service** (Python) - Aggregates all services with web UI at `dashboard-service:5000`

2. **Observability Layer** - Production monitoring stack:
   - **Prometheus** - Metrics collection, scraping every 15s at port `9090`
   - **Grafana** - Visualization dashboards at port `3000` (admin/admin)

All services communicate via REST APIs and Docker networking. Services discover each other by container name (e.g., `http://time-service:5001`).

### Key Patterns

- **Polyglot architecture**: Each service uses the best language for its task (Go for performance, Node.js for async I/O, Python for system libraries and web UI)
- **Service independence**: Each service has its own Dockerfile, dependencies, and can be scaled independently
- **Graceful degradation**: Dashboard continues working even when backend services fail
- **Performance optimizations**: Parallel API calls using ThreadPoolExecutor, intelligent caching (10min for weather data), reduced timeouts
- **Real-time updates**: JavaScript polling for live clock updates in the browser
- **Prometheus instrumentation**: All services expose `/metrics` endpoints with custom metrics

## Common Development Commands

### Building and Running

```bash
# Navigate to microservices project
cd 1-microservices_test

# Build and start all services (including Prometheus/Grafana)
docker-compose up --build

# Start in detached mode
docker-compose up -d

# Rebuild single service
docker-compose build <service-name>
docker-compose up -d <service-name>

# Stop all services
docker-compose down

# View logs
docker-compose logs -f
docker-compose logs <service-name>
```

### Testing and Monitoring

```bash
# Access dashboards
# Main dashboard: http://localhost:5000
# Grafana: http://localhost:3000 (admin/admin)
# Prometheus: http://localhost:9090

# Test individual services
curl http://localhost:5001/api/time
curl http://localhost:5002/api/sysinfo
curl http://localhost:5003/api/weather
curl http://localhost:5000/api/aggregate

# View Prometheus metrics
curl http://localhost:5001/metrics
curl http://localhost:5002/metrics
curl http://localhost:5003/metrics
curl http://localhost:5000/metrics

# Generate traffic for monitoring (requires bash)
./scripts/generate-traffic.sh -m balanced -d 60 -r 10    # Balanced load
./scripts/generate-traffic.sh -m spike -r 50             # Traffic spike
./scripts/generate-traffic.sh -m stress -d 300           # Stress test

# Check Prometheus alerts
curl http://localhost:9090/api/v1/alerts | jq

# Scale a service
docker-compose up --scale time-service=3

# Test performance
time curl -s http://localhost:5000/ > /dev/null
time curl -s http://localhost:5000/api/aggregate > /dev/null
```

## Service Implementation Details

### Service Endpoints Structure

Each service follows a consistent pattern:
- `/api/<resource>` - Main API endpoint (JSON response)
- `/health` - Health check endpoint
- `/metrics` - Prometheus metrics endpoint

### Prometheus Metrics

All services are instrumented with:
- **Request counters**: `<service>_http_requests_total` with labels for endpoint, method, status
- **Latency histograms**: `<service>_http_request_duration_seconds` for p50, p95, p99 percentiles
- **Custom metrics**:
  - Weather service: `weather_service_cache_hits_total`, `weather_service_cache_misses_total`
  - Dashboard: `dashboard_service_upstream_request_duration_seconds` for tracking backend service latency

### Service Communication Flow

```
Browser → Dashboard Service (port 5000)
          ↓ (parallel calls using ThreadPoolExecutor)
          ├→ Time Service (port 5001)
          ├→ System Info Service (port 5002)
          └→ Weather Service (port 5003) → External API (wttr.in)

All services → Prometheus (port 9090) [scrapes /metrics every 15s]
               ↓
               Grafana (port 3000) [queries Prometheus for visualization]
```

### Docker Networking

Services resolve each other using Docker Compose service names:
- `http://time-service:5001` (not `http://localhost:5001` from inside containers)
- `http://system-info-service:5002`
- `http://weather-service:5003`
- Browser requests go to `http://localhost:5000` (dashboard acts as proxy)

## Important Implementation Notes

### Multi-stage Builds

The Go time service uses multi-stage Docker builds to minimize image size:
1. Build stage: Uses `golang:1.21-alpine` with full toolchain
2. Runtime stage: Uses `alpine:latest` with only the compiled binary
3. Result: Much smaller final image (~15MB vs ~300MB)

### Cross-Platform Compatibility

The project works on Windows, Linux, and macOS:
- Docker Compose uses environment variable fallbacks: `${HOSTNAME:-${COMPUTERNAME:-localhost}}`
- Weather service uses `certifi` package for consistent SSL certificate handling across platforms
- Traffic generation script requires bash (use Git Bash on Windows or WSL)

### Performance Optimizations

The dashboard service includes critical optimizations:
1. **Parallel API calls**: Uses `ThreadPoolExecutor` to call all backend services simultaneously
2. **Reduced timeouts**: Fail-fast approach (3s for most services, 2s for proxy)
3. **Weather caching**: 10-minute cache to reduce external API calls
4. **Real-time updates**: JavaScript polls `/api/time-proxy` every second for live clock

### Monitoring Configuration

- **Scrape interval**: 15s (configured in `monitoring/prometheus.yml`)
- **Evaluation interval**: 10s for alert rules
- **Alert rules**: 11 total alerts covering performance, traffic, errors, resources, and availability
- **Grafana dashboard**: Pre-provisioned "Microservices Overview Dashboard" with 11 panels
- **Dashboard refresh**: Auto-refresh every 5 seconds

## Troubleshooting

### Docker daemon issues
- Linux: `sudo systemctl start docker`
- Windows: Ensure Docker Desktop is running (check system tray icon)

### Port conflicts
Modify port mappings in `docker-compose.yml` if ports 5000-5003, 3000, or 9090 are in use.

### Service won't start
```bash
# Check logs
docker-compose logs <service-name>

# Rebuild from scratch
docker-compose down
docker-compose build --no-cache <service-name>
docker-compose up
```

### Prometheus not collecting metrics
```bash
# Check Prometheus targets
# Visit http://localhost:9090/targets
# All targets should show "UP" status

# Verify metrics endpoints are accessible
curl http://localhost:5001/metrics
```

### Grafana shows no data
1. Verify Prometheus is running: `docker ps | grep prometheus`
2. Check datasource configuration in Grafana (should be auto-provisioned)
3. Ensure time range in dashboard covers period when services were running

## File Structure

```
devops-progress/
├── 1-microservices_test/           # Main microservices project
│   ├── time-service/               # Go service
│   │   ├── main.go                 # HTTP server with Prometheus metrics
│   │   ├── go.mod                  # Go dependencies
│   │   └── Dockerfile              # Multi-stage build
│   ├── system-info-service/        # Python service
│   │   ├── app.py                  # Flask app with psutil
│   │   ├── requirements.txt        # Python deps + prometheus-client
│   │   └── Dockerfile
│   ├── weather-service/            # Node.js service
│   │   ├── server.js               # Express + axios + caching
│   │   ├── package.json            # npm deps + prom-client
│   │   └── Dockerfile
│   ├── dashboard-service/          # Python aggregator
│   │   ├── app.py                  # Flask with ThreadPoolExecutor
│   │   ├── requirements.txt
│   │   └── Dockerfile
│   ├── monitoring/                 # Monitoring stack configuration
│   │   ├── prometheus.yml          # Scrape configs + alert rules
│   │   ├── alert-rules.yml         # 11 alert definitions
│   │   └── grafana/provisioning/   # Auto-configured datasources + dashboards
│   ├── scripts/
│   │   └── generate-traffic.sh     # Traffic generation tool (5 modes)
│   ├── docker-compose.yml          # Orchestrates all 6 containers
│   ├── README.md                   # Detailed project documentation
│   └── MONITORING.md               # Monitoring setup guide
└── README.md                       # Repository overview
```

## Development Workflow

When making changes to a service:

1. Edit the service code
2. Rebuild only that service: `docker-compose build <service-name>`
3. Restart the service: `docker-compose up -d <service-name>`
4. Check logs: `docker-compose logs -f <service-name>`
5. Test the endpoint: `curl http://localhost:<port>/api/<endpoint>`
6. Verify metrics are updating: `curl http://localhost:<port>/metrics`
7. Check Grafana dashboard for real-time impact

## Next Learning Steps

According to the project roadmap, upcoming topics include:
- Service discovery (Consul, Eureka)
- API gateways (Kong, Nginx)
- Kubernetes deployment
- Logging aggregation (ELK stack, Loki)
- Message queues (RabbitMQ, Kafka)
- Distributed tracing (Jaeger, Zipkin)
- Service mesh (Istio, Linkerd)
