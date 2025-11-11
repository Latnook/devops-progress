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

## Key Microservices Concepts Demonstrated

- **Service Independence**: Each service runs in its own container
- **API Communication**: Services communicate via REST APIs
- **Service Discovery**: Services find each other using Docker networking
- **External API Integration**: Weather service demonstrates integration with external APIs
- **Scalability**: Each service can be scaled independently
- **Containerization**: Each service is containerized with Docker
- **Health Checks**: All services have health check endpoints
- **System Monitoring**: Detailed system metrics collection using psutil

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
- You'll see a nice dashboard showing data from both services
- Click "Refresh Data" to see the time update

**Individual Service APIs**:
- Time Service: http://localhost:5001/api/time
- System Info Service: http://localhost:5002/api/sysinfo
- Weather Service: http://localhost:5003/api/weather
- Dashboard API (aggregated): http://localhost:5000/api/aggregate

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
```bash
sudo systemctl start docker
```

### Permission denied
```bash
sudo usermod -aG docker $USER
# Log out and log back in
```

### Port already in use
If ports 5000, 5001, 5002, or 5003 are in use, modify the ports in `docker-compose.yml`

### View logs
```bash
docker-compose logs -f
```

## Learning Exercises

Try these to learn more:

1. **Scale a service**:
   ```bash
   docker-compose up --scale time-service=3
   ```

2. **Stop one service** and see what happens to the dashboard

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
