# Monitoring & Alerting Guide

This document explains how to use the Prometheus monitoring and Grafana visualization setup for the microservices project.

## Quick Start

### Access Dashboards

| Service | URL | Credentials |
|---------|-----|-------------|
| **Grafana Dashboard** | http://localhost:3000 | admin / admin |
| **Prometheus UI** | http://localhost:9090 | None |
| **Metrics Endpoints** | http://localhost:500X/metrics | None |

### View Pre-built Dashboard

1. Open http://localhost:3000
2. Login with `admin` / `admin`
3. Navigate to **Dashboards** → **Microservices Overview Dashboard**

## Traffic Generation

Use the built-in traffic generator to populate metrics and test alerting:

```bash
# Balanced traffic for 60 seconds at 5 req/s
./scripts/generate-traffic.sh -d 60 -r 5 -m balanced

# Traffic spike to test autoscaling
./scripts/generate-traffic.sh -m spike -r 50

# Periodic bursts
./scripts/generate-traffic.sh -m burst -d 120

# Heavy sustained load
./scripts/generate-traffic.sh -m heavy -r 20 -d 180

# Stress test to trigger alerts
./scripts/generate-traffic.sh -m stress -d 300
```

### Traffic Modes Explained

- **balanced**: Equal load across all services (good for baseline metrics)
- **spike**: Sudden traffic increase (tests scaling behavior)
- **burst**: Periodic bursts with quiet periods (simulates real-world patterns)
- **heavy**: High sustained load (capacity testing)
- **stress**: Very high load to trigger alerts and find breaking points

## Available Metrics

### Time Service (Go)
- `time_service_http_requests_total` - Total HTTP requests by endpoint, method, status
- `time_service_http_request_duration_seconds` - Request latency histogram

### System Info Service (Python)
- `system_info_service_http_requests_total` - HTTP request counter
- `system_info_service_http_request_duration_seconds` - Request latency

### Weather Service (Node.js)
- `weather_service_http_requests_total` - HTTP request counter
- `weather_service_http_request_duration_seconds` - Request latency
- `weather_service_cache_hits_total` - Cache hit counter
- `weather_service_cache_misses_total` - Cache miss counter
- `process_resident_memory_bytes` - Memory usage
- `process_cpu_seconds_total` - CPU usage

### Dashboard Service (Python)
- `dashboard_service_http_requests_total` - HTTP request counter
- `dashboard_service_http_request_duration_seconds` - Request latency
- `dashboard_service_upstream_request_duration_seconds` - Upstream service call latency

## Prometheus Queries (PromQL)

### Request Rate
```promql
# Requests per second for all services
sum by (job) (rate({__name__=~".*http_requests_total"}[1m]))

# Time service request rate
rate(time_service_http_requests_total[1m])
```

### Latency
```promql
# Average latency
rate(time_service_http_request_duration_seconds_sum[1m]) / rate(time_service_http_request_duration_seconds_count[1m])

# 95th percentile latency
histogram_quantile(0.95, rate(time_service_http_request_duration_seconds_bucket[5m]))

# 99th percentile latency
histogram_quantile(0.99, rate(weather_service_http_request_duration_seconds_bucket[5m]))
```

### Cache Performance
```promql
# Cache hit rate (percentage)
rate(weather_service_cache_hits_total[5m]) / (rate(weather_service_cache_hits_total[5m]) + rate(weather_service_cache_misses_total[5m])) * 100

# Total cache operations
weather_service_cache_hits_total + weather_service_cache_misses_total
```

### Error Rates
```promql
# Error rate
rate(time_service_http_requests_total{status="500"}[1m])

# Error percentage
rate(time_service_http_requests_total{status="500"}[1m]) / rate(time_service_http_requests_total[1m]) * 100
```

## Active Alerts

The system monitors for these conditions:

### Performance Alerts
- **HighLatency**: Response time > 500ms for 1 minute
- **WeatherServiceHighLatency**: Weather API latency > 2s for 2 minutes
- **UpstreamServiceSlow**: Dashboard upstream calls > 1s for 3 minutes

### Traffic Alerts
- **HighRequestRate**: Request rate > 10 req/s for 2 minutes
- **TrafficSpike**: Traffic increased 2x compared to 5-minute average
- **NoTraffic**: No requests received for 5 minutes

### Error Alerts
- **HighErrorRate**: Error rate > 5% for 2 minutes

### Resource Alerts
- **HighMemoryUsage**: Weather service memory > 200MB for 5 minutes
- **LowCacheHitRate**: Cache hit rate < 50% for 5 minutes

### Availability Alerts
- **ServiceDown**: Service unreachable for 1 minute
- **PrometheusDown**: Prometheus monitoring down for 30 seconds

## Viewing Alerts

### In Prometheus UI
1. Open http://localhost:9090
2. Click **Alerts** in the top menu
3. View active, pending, and firing alerts

### Via API
```bash
# Get all alerts
curl -s http://localhost:9090/api/v1/alerts | jq

# Count firing alerts
curl -s http://localhost:9090/api/v1/alerts | jq '.data.alerts[] | select(.state=="firing") | .labels.alertname'
```

## Dashboard Panels

The **Microservices Overview Dashboard** includes:

1. **Request Rate** - Line chart showing req/s by service
2. **Average Response Time** - Gauge meters for current latency
3. **Time Service Latency Percentiles** - p50, p95, p99
4. **Weather Service Latency Percentiles** - p50, p95, p99
5. **Cache Performance** - Hits vs misses over time
6. **Cache Hit Rate %** - Gauge showing effectiveness
7. **Upstream Service Latency** - Dashboard → Service call times
8. **Total Request Counters** - Cumulative requests per service

## Creating Custom Dashboards

1. Click **+** → **Create Dashboard** in Grafana
2. Add panels with PromQL queries
3. Customize visualizations (time series, gauges, stat panels)
4. Set refresh interval (5s, 10s, 30s, 1m)
5. Save dashboard

## Troubleshooting

### No Data in Grafana
- Check Prometheus is running: `docker ps | grep prometheus`
- Verify metrics endpoints: `curl http://localhost:5001/metrics`
- Check Prometheus targets: http://localhost:9090/targets
- Ensure datasource is configured correctly in Grafana

### Alerts Not Firing
- Check alert rules are loaded: `curl http://localhost:9090/api/v1/rules`
- Verify alert conditions match current metrics
- Check evaluation interval in prometheus.yml (10s)
- Generate traffic to trigger alert conditions

### High Latency
- Check weather service cache hit rate
- Monitor upstream service dependencies
- Look for slow database queries or external API calls
- Consider scaling services horizontally

## Next Steps

1. **Set up Alertmanager** - Configure email/Slack notifications
2. **Add Service Level Objectives (SLOs)** - Define uptime and latency targets
3. **Implement Distributed Tracing** - Add Jaeger or Zipkin
4. **Create Runbooks** - Document response procedures for each alert
5. **Horizontal Scaling** - Add docker-compose scaling or move to Kubernetes

## Resources

- [Prometheus Documentation](https://prometheus.io/docs/)
- [PromQL Basics](https://prometheus.io/docs/prometheus/latest/querying/basics/)
- [Grafana Dashboards](https://grafana.com/docs/grafana/latest/dashboards/)
- [Alerting Best Practices](https://prometheus.io/docs/practices/alerting/)
