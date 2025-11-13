# Microservices Demo Project

A demonstration of **polyglot microservices architecture** using Docker, Docker Compose, and multiple programming languages (Go, Node.js, Python), showcasing how different languages can work together seamlessly through REST APIs.

**Latest Update: 2025-11-13** - Converted to polyglot architecture with Go, Node.js, and Python services!

## Architecture

This project demonstrates a microservices architecture with four independent services:

```
┌─────────────────────┐
│  Dashboard Service  │ ← Main entry point (Port 5000)
│   (Aggregator)      │
└──────────┬──────────┘
           │
           ├─────────────────┬─────────────────┐
           │                 │                 │
           ▼                 ▼                 ▼
  ┌─────────────┐   ┌──────────────┐   ┌──────────────┐
  │Time Service │   │System Info   │   │Weather Service│
  │ (Port 5001) │   │Service       │   │  (Port 5003) │
  │             │   │(Port 5002)   │   │              │
  └─────────────┘   └──────────────┘   └──────────────┘
```

### Services:

1. **Time Service** (port 5001) - **Written in Go** 🚀
   - Blazing fast compiled service using Go's native HTTP server
   - Returns current timestamp
   - Independent microservice
   - REST API endpoint: `/api/time`
   - **Why Go?** Perfect for simple, high-performance services with low memory footprint

2. **System Info Service** (port 5002) - **Written in Python** 🐍
   - Returns detailed system information:
     - OS version and kernel release
     - CPU architecture and core count
     - Memory statistics (total, available, usage %)
     - Python version
   - Independent microservice
   - REST API endpoint: `/api/sysinfo`
   - **Why Python?** Excellent libraries (psutil) for system information gathering

3. **Weather Service** (port 5003) - **Written in Node.js** 🟢
   - Fetches real-time weather data for Haifa, Israel
   - Integrates with wttr.in weather API using Axios
   - Returns temperature, humidity, wind speed, and conditions
   - Includes intelligent caching (10 minutes)
   - REST API endpoint: `/api/weather`
   - **Why Node.js?** Perfect for async I/O operations and external API calls

4. **Dashboard Service** (port 5000) - **Written in Python** 🐍
   - Aggregates data from all three services
   - Demonstrates service-to-service communication across different languages
   - Provides both web UI and REST API endpoint
   - Displays all data in a user-friendly interface
   - **Real-time clock updates**: Time ticks live every second using JavaScript
   - **Graceful degradation**: Dashboard continues working even if services fail
   - **Parallel API calls**: Uses ThreadPoolExecutor for concurrent requests
   - **Why Python?** Flask makes it easy to build web UIs and aggregate data

## Key Microservices Concepts Demonstrated

- **Polyglot Architecture** ⭐ **NEW (2025-11-13)**: Services written in Go, Node.js, and Python working together
- **Language-Agnostic Communication**: REST APIs allow different languages to communicate seamlessly
- **Service Independence**: Each service runs in its own container with its own runtime
- **API Communication**: Services communicate via REST APIs using JSON
- **Service Discovery**: Services find each other using Docker networking (service name resolution)
- **External API Integration**: Weather service demonstrates integration with external APIs
- **Scalability**: Each service can be scaled independently
- **Containerization**: Each service is containerized with Docker using language-specific base images
- **Multi-stage Builds**: Go service uses multi-stage Docker builds for minimal image size
- **Health Checks**: All services have health check endpoints
- **System Monitoring**: Detailed system metrics collection using psutil
- **Graceful Degradation**: Dashboard continues functioning when services fail
- **Real-time Updates**: Live clock using JavaScript and AJAX polling
- **Performance Optimization**: Parallel API calls, intelligent caching, and reduced timeouts
- **Asynchronous Operations**: Using ThreadPoolExecutor for concurrent service calls
- **Best Tool for the Job**: Each service uses the language best suited for its task

## Polyglot Microservices Architecture (Added: 2025-11-13)

This project demonstrates a **true polyglot architecture** where services are written in different programming languages but work together seamlessly through REST APIs and Docker containers.

### Why Polyglot?

**Advantages:**
- **Right tool for the job**: Use the best language for each specific task
- **Team autonomy**: Different teams can use their preferred languages
- **Performance optimization**: Optimize critical services without rewriting everything
- **Learning opportunity**: Explore different languages in a practical context
- **Technology flexibility**: Not locked into a single language ecosystem

**How It Works:**
1. **Docker** abstracts away language differences - each service runs in its own container
2. **REST APIs** provide language-agnostic communication using HTTP and JSON
3. **Docker networking** allows services to discover each other by name
4. Services don't need to know what language other services are written in!

### Language Choices Explained

| Service | Language | Why This Language? | Key Features |
|---------|----------|-------------------|--------------|
| **Time Service** | Go | Fast, compiled, low memory usage | Native HTTP server, no frameworks needed |
| **Weather Service** | Node.js | Excellent for async I/O and external APIs | Non-blocking I/O, great npm ecosystem (axios) |
| **System Info** | Python | Rich system libraries (psutil) | Easy to work with system information |
| **Dashboard** | Python | Quick web development with Flask | Simple templating, easy aggregation logic |

### Technical Implementation

**Go Service (time-service/main.go):**
```go
package main

import (
    "encoding/json"
    "net/http"
    "time"
)

func getTimeHandler(w http.ResponseWriter, r *http.Request) {
    currentTime := time.Now().Format("2006-01-02 15:04:05")
    response := TimeResponse{
        Service:   "time-service",
        Timestamp: currentTime,
    }
    w.Header().Set("Content-Type", "application/json")
    json.NewEncoder(w).Encode(response)
}
```

**Node.js Service (weather-service/server.js):**
```javascript
const express = require('express');
const axios = require('axios');

app.get('/api/weather', async (req, res) => {
    const weatherUrl = 'https://wttr.in/Haifa,Israel?format=j1';
    const weatherResponse = await axios.get(weatherUrl, { timeout: 5000 });
    res.json(responseData);
});
```

**Python Service (system-info-service/app.py):**
```python
import psutil
from flask import Flask, jsonify

@app.route('/api/sysinfo', methods=['GET'])
def get_system_info():
    return jsonify({
        'cpu_count': psutil.cpu_count(),
        'memory_total_gb': round(psutil.virtual_memory().total / (1024**3), 2)
    })
```

### Docker Configuration for Polyglot Services

**Multi-stage build for Go (smaller images):**
```dockerfile
FROM golang:1.21-alpine AS builder
WORKDIR /app
COPY go.mod main.go ./
RUN go build -o time-service main.go

FROM alpine:latest
COPY --from=builder /app/time-service .
CMD ["./time-service"]
```

**Node.js with package management:**
```dockerfile
FROM node:18-alpine
WORKDIR /app
COPY package.json ./
RUN npm install --production
COPY server.js ./
CMD ["npm", "start"]
```

**Python with Flask:**
```dockerfile
FROM python:3.11-slim
WORKDIR /app
COPY requirements.txt .
RUN pip install --no-cache-dir -r requirements.txt
COPY app.py .
CMD ["python", "app.py"]
```

## Performance Optimizations (Added: 2025-11-12)

The dashboard has been **heavily optimized for performance** with the following improvements:

### Optimization Features

1. **Parallel API Calls** - All microservice calls are now made simultaneously using Python's `ThreadPoolExecutor`
   - **Before**: Services called sequentially (5s + 5s + 10s = 20s worst case)
   - **After**: Services called in parallel (max 5s for fastest optimization)
   - **Speed improvement**: Up to 75% faster initial page load

2. **Intelligent Caching** - Weather data is cached for 10 minutes
   - Weather doesn't change every second, so why fetch it every time?
   - Dramatically reduces external API calls and load times
   - Cache status displayed on dashboard with age indicator
   - Graceful degradation: Returns stale cache if API fails

3. **Reduced Timeouts** - Fail-fast approach for better UX
   - Time service: 5s → 3s
   - System info: 5s → 3s
   - Weather service: 10s → 5s
   - Time proxy: 5s → 2s
   - Users don't wait unnecessarily for slow services

4. **Visual Performance Indicators**
   - Green banner showing optimizations are active
   - Cache badges showing when data is cached
   - Cache age display in seconds
   - Stale cache warnings when using fallback data

### Performance Results

**Typical load times with cache:**
- Dashboard page: ~20ms (0.02 seconds)
- API aggregate: ~10ms (0.01 seconds)
- Weather service (cached): Instant response

**Without cache (first load):**
- Still significantly faster due to parallel processing
- Maximum wait time = slowest service (not sum of all)

## Real-Time Features (Added: 2025-11-12)

The dashboard now includes **real-time clock updates** that demonstrate modern web application patterns:

### How It Works

1. **JavaScript Polling**: The dashboard uses `setInterval()` to poll the time service every second
2. **AJAX Requests**: Uses Fetch API to make asynchronous calls to `/api/time-proxy`
3. **Proxy Endpoint**: Dashboard service provides `/api/time-proxy` that forwards requests to the time service
4. **Live Status Indicator**: Shows green "Live" status when service is running, red "Offline" if it fails
5. **DOM Updates**: JavaScript updates the page without refreshing using `document.getElementById()`

### Implementation Details

**New API Endpoint** (`/api/time-proxy`):
```python
@app.route('/api/time-proxy', methods=['GET'])
def time_proxy():
    try:
        time_response = requests.get(TIME_SERVICE_URL, timeout=5)
        return jsonify(time_response.json())
    except Exception as e:
        return jsonify({'service': 'time-service', 'timestamp': f'Error: {str(e)}'}), 500
```

**JavaScript Auto-Update**:
```javascript
function updateTime() {
    fetch('/api/time-proxy')
        .then(response => response.json())
        .then(data => {
            document.getElementById('current-time').textContent = data.timestamp;
            document.getElementById('time-status').style.color = '#4CAF50';
            document.getElementById('time-status-text').textContent = 'Live';
        })
        .catch(error => {
            document.getElementById('current-time').textContent = 'Service unavailable';
            document.getElementById('time-status').style.color = '#d32f2f';
            document.getElementById('time-status-text').textContent = 'Offline';
        });
}

// Update every second
setInterval(updateTime, 1000);
```

### Why This Pattern?

- **Browser Limitation**: Browsers cannot resolve Docker service names (e.g., `http://time-service:5001`)
- **Proxy Solution**: Dashboard acts as a proxy between browser and internal services
- **Real-time UX**: Users see live updates without manual refresh
- **Resilience Testing**: Watch the status indicator turn red when you stop a service

## Prerequisites

You need to install the following on your computer:

1. **Docker** - Container platform
   - Linux: `sudo dnf install docker` or `sudo apt install docker.io`
   - Mac: Download Docker Desktop from docker.com
   - Windows: Download Docker Desktop from docker.com

2. **Docker Compose** - Multi-container orchestration
   - Usually comes with Docker Desktop
   - Linux: `sudo dnf install docker-compose` or `sudo apt install docker-compose`

3. **Verify Installation**:
   ```bash
   docker --version
   docker-compose --version
   ```

### Windows Users
This project is fully compatible with Windows! The docker-compose configuration uses cross-platform environment variable fallbacks:
- Uses `HOSTNAME` on Linux/Mac
- Falls back to `COMPUTERNAME` on Windows
- Defaults to `localhost` if neither is set

**Windows SSL Certificate Fix (Added: 2025-11-12)**:
The weather service now uses the `certifi` package to handle SSL certificate verification for HTTPS requests to the wttr.in API. This ensures reliable SSL connections across all platforms (Windows, Linux, macOS) by providing a consistent CA certificate bundle.

Make sure Docker Desktop is running before executing `docker-compose up --build`.

## How to Run

### Step 1: Navigate to the project directory
```bash
cd 1-microservices_test
```

### Step 2: Start all services
```bash
docker-compose up --build
```

This command will:
- Build Docker images for all four services
- Create containers
- Start all services
- Set up networking between them

### Step 3: Access the services

**Web Dashboard (Recommended)**:
- Open your browser and go to: http://localhost:5000
- You'll see a nice dashboard showing data from all services
- **Watch the clock tick in real-time** - it updates every second automatically!
- The status indicator shows green when services are live
- Click "Refresh Data" to reload all other service data

**Individual Service APIs**:
- Time Service: http://localhost:5001/api/time
- System Info Service: http://localhost:5002/api/sysinfo
- Weather Service: http://localhost:5003/api/weather
- Dashboard API (aggregated): http://localhost:5000/api/aggregate
- Time Proxy (for browser polling): http://localhost:5000/api/time-proxy

### Step 4: Stop the services
Press `Ctrl+C` in the terminal, then run:
```bash
docker-compose down
```

## Understanding the Code

### Time Service (time-service/main.go) - Go
```go
func getTimeHandler(w http.ResponseWriter, r *http.Request) {
    currentTime := time.Now().Format("2006-01-02 15:04:05")
    response := TimeResponse{
        Service:   "time-service",
        Timestamp: currentTime,
    }
    w.Header().Set("Content-Type", "application/json")
    json.NewEncoder(w).Encode(response)
}
```

### System Info Service (system-info-service/app.py) - Python
```python
@app.route('/api/sysinfo', methods=['GET'])
def get_system_info():
    # Collects detailed system metrics
    system_info = {
        'hostname': hostname,
        'platform': platform.system(),
        'platform_release': platform.release(),
        'cpu_count': psutil.cpu_count(logical=True),
        'memory_total_gb': round(psutil.virtual_memory().total / (1024**3), 2),
        'python_version': platform.python_version()
    }
    return jsonify(system_info)
```

### Weather Service (weather-service/server.js) - Node.js
```javascript
const express = require('express');
const axios = require('axios');

app.get('/api/weather', async (req, res) => {
    try {
        const weatherUrl = 'https://wttr.in/Haifa,Israel?format=j1';
        const weatherResponse = await axios.get(weatherUrl, { timeout: 5000 });
        const weatherData = weatherResponse.data;
        // Process and return weather data with caching
        res.json(responseData);
    } catch (error) {
        res.status(500).json({ error: error.message });
    }
});
```

### Dashboard Service (dashboard-service/app.py) - Python
```python
# This service CALLS all other services
time_response = requests.get('http://time-service:5001/api/time')
sysinfo_response = requests.get('http://system-info-service:5002/api/sysinfo')
weather_response = requests.get('http://weather-service:5003/api/weather')
```

## Project Structure

```
1-microservices_test/
├── time-service/               [Go Service]
│   ├── main.go                # Go HTTP server
│   ├── go.mod                 # Go module definition
│   └── Dockerfile             # Multi-stage build for Go
├── system-info-service/        [Python Service]
│   ├── app.py                 # Flask application with psutil
│   ├── Dockerfile             # Python container
│   └── requirements.txt       # Python dependencies
├── weather-service/            [Node.js Service]
│   ├── server.js              # Express server with axios
│   ├── package.json           # npm dependencies
│   └── Dockerfile             # Node.js container
├── dashboard-service/          [Python Service]
│   ├── app.py                 # Flask aggregator with web UI
│   ├── Dockerfile             # Python container
│   └── requirements.txt       # Flask and requests
├── docker-compose.yml         # Orchestrates all polyglot services
└── README.md                  # This file

Note: Legacy Python files (app.py in time/weather services) are kept for reference
but are not used in the current polyglot architecture.
```

## Troubleshooting

### Docker daemon not running

**Windows:**
- Open Docker Desktop application and wait for it to fully start
- The Docker whale icon in system tray should be steady (not animated)

**Linux:**
```bash
sudo systemctl start docker
```

### Permission denied (Linux only)
```bash
sudo usermod -aG docker $USER
# Log out and log back in
```

### Port already in use
If ports 5000, 5001, 5002, or 5003 are in use, modify the ports in `docker-compose.yml`

### HOSTNAME variable warning (Fixed)
This has been resolved with cross-platform environment variable fallbacks. The project now works seamlessly on Windows, Linux, and Mac.

### Weather service SSL errors on Windows (Fixed)
**Issue**: Weather service fails to fetch data from wttr.in API with SSL certificate verification errors on Windows.

**Solution**: The weather service now uses the `certifi` package which provides Mozilla's CA certificate bundle. This ensures consistent SSL verification across all platforms.

**Technical details**:
- Added `certifi==2024.8.30` to `weather-service/requirements.txt`
- Modified the HTTPS request to use `verify=certifi.where()`
- This fix works on Windows, Linux, and macOS without any platform-specific changes

If you still see weather errors after this fix, rebuild the weather service container:
```bash
docker-compose build weather-service
docker-compose up -d
```

### View logs
```bash
docker-compose logs -f
```

## Learning Exercises

Try these to learn more:

1. **Test Performance** (NEW - Recommended!)
   ```bash
   # Start all services
   docker-compose up -d

   # Open http://localhost:5000 and notice the green performance banner
   # The page loads almost instantly!

   # Test load time from command line
   time curl -s http://localhost:5000/ > /dev/null

   # Notice the CACHED badge on weather data - refresh to see cache age
   # After 10 minutes, the cache expires and fresh data is fetched

   # Test the API aggregate endpoint
   time curl -s http://localhost:5000/api/aggregate > /dev/null

   # Compare: This used to take up to 20 seconds, now it's milliseconds!
   ```
   This demonstrates **performance optimization** - a critical production skill!

2. **Test Resilience** (Also recommended!):
   ```bash
   # Start all services in detached mode
   docker-compose up -d

   # Open http://localhost:5000 and watch the live clock

   # Stop the time service
   docker-compose stop time-service

   # Watch the dashboard: clock turns red and shows "Offline"
   # But other services continue working!

   # Restart the service
   docker-compose start time-service

   # Watch the clock turn green and resume ticking
   ```
   This demonstrates **graceful degradation** - a key microservices principle!

3. **Scale a service**:
   ```bash
   docker-compose up --scale time-service=3
   ```

4. **Modify the services** to return different data

5. **Add a new service** following the same pattern

6. **Check running containers**:
   ```bash
   docker ps
   ```

7. **View service logs**:
   ```bash
   docker-compose logs time-service
   ```

## Why Microservices?

**Advantages** (compared to monolithic):
- Each service can be developed, deployed, and scaled independently
- Different services can use different technologies
- Failure in one service doesn't crash the entire system
- Easier to understand and maintain smaller codebases

**Disadvantages**:
- More complex infrastructure
- Network latency between services
- Requires good DevOps practices
- More overhead for small applications

## Next Steps

1. Learn about **service discovery** (Consul, Eureka)
2. Learn about **API gateways** (Kong, Nginx)
3. Learn about **container orchestration** (Kubernetes)
4. Learn about **monitoring and logging** (Prometheus, ELK stack)
5. Learn about **message queues** (RabbitMQ, Kafka) for async communication
