# Microservices Demo Project

A demonstration of microservices architecture using Docker, Docker Compose, Python Flask, and external API integration.

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

1. **Time Service** (port 5001)
   - Returns current timestamp
   - Independent microservice
   - REST API endpoint: `/api/time`

2. **System Info Service** (port 5002)
   - Returns detailed system information:
     - OS version and kernel release
     - CPU architecture and core count
     - Memory statistics (total, available, usage %)
     - Python version
   - Independent microservice
   - REST API endpoint: `/api/sysinfo`

3. **Weather Service** (port 5003)
   - Fetches real-time weather data for Haifa, Israel
   - Integrates with wttr.in weather API
   - Returns temperature, humidity, wind speed, and conditions
   - REST API endpoint: `/api/weather`

4. **Dashboard Service** (port 5000)
   - Aggregates data from all three services
   - Demonstrates service-to-service communication
   - Provides both web UI and REST API endpoint
   - Displays all data in a user-friendly interface
   - **Real-time clock updates**: Time ticks live every second using JavaScript
   - **Graceful degradation**: Dashboard continues working even if services fail

## Key Microservices Concepts Demonstrated

- **Service Independence**: Each service runs in its own container
- **API Communication**: Services communicate via REST APIs
- **Service Discovery**: Services find each other using Docker networking
- **External API Integration**: Weather service demonstrates integration with external APIs
- **Scalability**: Each service can be scaled independently
- **Containerization**: Each service is containerized with Docker
- **Health Checks**: All services have health check endpoints
- **System Monitoring**: Detailed system metrics collection using psutil
- **Graceful Degradation**: Dashboard continues functioning when services fail
- **Real-time Updates**: Live clock using JavaScript and AJAX polling

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

### Time Service (time-service/app.py)
```python
@app.route('/api/time', methods=['GET'])
def get_time():
    current_time = datetime.now().strftime('%Y-%m-%d %H:%M:%S')
    return jsonify({'service': 'time-service', 'timestamp': current_time})
```

### System Info Service (system-info-service/app.py)
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

### Weather Service (weather-service/app.py)
```python
@app.route('/api/weather', methods=['GET'])
def get_weather():
    # Fetches real-time weather for Haifa, Israel
    weather_url = 'https://wttr.in/Haifa,Israel?format=j1'
    weather_response = requests.get(weather_url, timeout=5)
    weather_data = weather_response.json()
    return jsonify(weather_info)
```

### Dashboard Service (dashboard-service/app.py)
```python
# This service CALLS all other services
time_response = requests.get('http://time-service:5001/api/time')
sysinfo_response = requests.get('http://system-info-service:5002/api/sysinfo')
weather_response = requests.get('http://weather-service:5003/api/weather')
```

## Project Structure

```
1-microservices_test/
├── time-service/
│   ├── app.py              # Flask application
│   ├── Dockerfile          # Container definition
│   └── requirements.txt    # Python dependencies
├── system-info-service/
│   ├── app.py              # Enhanced with psutil
│   ├── Dockerfile
│   └── requirements.txt
├── weather-service/
│   ├── app.py              # Weather API integration
│   ├── Dockerfile
│   └── requirements.txt
├── dashboard-service/
│   ├── app.py              # Aggregates all services
│   ├── Dockerfile
│   └── requirements.txt
├── docker-compose.yml      # Orchestration configuration
└── README.md
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

### View logs
```bash
docker-compose logs -f
```

## Learning Exercises

Try these to learn more:

1. **Test Resilience** (Recommended first exercise!):
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

2. **Scale a service**:
   ```bash
   docker-compose up --scale time-service=3
   ```

3. **Modify the services** to return different data

4. **Add a new service** following the same pattern

5. **Check running containers**:
   ```bash
   docker ps
   ```

6. **View service logs**:
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
