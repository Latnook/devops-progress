#!/bin/bash

# Traffic Generation Script for Microservices
# Generates realistic load patterns to populate monitoring dashboards

set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Configuration
DASHBOARD_URL="http://localhost:5000"
TIME_URL="http://localhost:5001/api/time"
SYSINFO_URL="http://localhost:5002/api/sysinfo"
WEATHER_URL="http://localhost:5003/api/weather"

# Default values
DURATION=60  # seconds
RPS=5        # requests per second
MODE="balanced"

# Help message
show_help() {
    cat << EOF
Usage: $0 [OPTIONS]

Generate traffic to microservices for monitoring and testing.

OPTIONS:
    -d, --duration SECONDS    Duration to run traffic (default: 60)
    -r, --rate RPS           Requests per second (default: 5)
    -m, --mode MODE          Traffic pattern mode (default: balanced)
                             Modes:
                               balanced  - Equal load across all services
                               spike     - Sudden traffic spike
                               burst     - Periodic bursts
                               heavy     - High sustained load
                               stress    - Very high load to trigger alerts
    -h, --help              Show this help message

EXAMPLES:
    # Generate balanced traffic for 2 minutes
    $0 -d 120 -r 10

    # Create traffic spike to test autoscaling
    $0 -m spike -r 50

    # Stress test to trigger alerts
    $0 -m stress -d 300

EOF
}

# Parse command line arguments
while [[ $# -gt 0 ]]; do
    case $1 in
        -d|--duration)
            DURATION="$2"
            shift 2
            ;;
        -r|--rate)
            RPS="$2"
            shift 2
            ;;
        -m|--mode)
            MODE="$2"
            shift 2
            ;;
        -h|--help)
            show_help
            exit 0
            ;;
        *)
            echo -e "${RED}Unknown option: $1${NC}"
            show_help
            exit 1
            ;;
    esac
done

# Calculate sleep interval between requests
SLEEP_INTERVAL=$(echo "scale=3; 1 / $RPS" | bc)

echo -e "${GREEN}═══════════════════════════════════════════════${NC}"
echo -e "${GREEN}  Microservices Traffic Generator${NC}"
echo -e "${GREEN}═══════════════════════════════════════════════${NC}"
echo -e "Mode:          ${YELLOW}$MODE${NC}"
echo -e "Duration:      ${YELLOW}${DURATION}s${NC}"
echo -e "Rate:          ${YELLOW}${RPS} req/s${NC}"
echo -e "Sleep:         ${YELLOW}${SLEEP_INTERVAL}s${NC}"
echo -e "${GREEN}═══════════════════════════════════════════════${NC}"
echo ""

# Counters
total_requests=0
successful_requests=0
failed_requests=0
start_time=$(date +%s)
end_time=$((start_time + DURATION))

# Function to make a request
make_request() {
    local url=$1
    local name=$2

    if curl -s -o /dev/null -w "%{http_code}" "$url" | grep -q "200"; then
        ((successful_requests++))
        return 0
    else
        ((failed_requests++))
        return 1
    fi
}

# Function for balanced mode
run_balanced() {
    while [ $(date +%s) -lt $end_time ]; do
        make_request "$TIME_URL" "Time" &
        make_request "$SYSINFO_URL" "SysInfo" &
        make_request "$WEATHER_URL" "Weather" &
        make_request "$DASHBOARD_URL" "Dashboard" &
        wait

        ((total_requests += 4))
        sleep "$SLEEP_INTERVAL"

        # Progress update every 10 requests
        if [ $((total_requests % 40)) -eq 0 ]; then
            elapsed=$(($(date +%s) - start_time))
            echo -e "${GREEN}✓${NC} Sent ${total_requests} requests in ${elapsed}s (Success: ${successful_requests}, Failed: ${failed_requests})"
        fi
    done
}

# Function for spike mode - sudden increase in traffic
run_spike() {
    echo -e "${YELLOW}Starting with low traffic...${NC}"

    # Low traffic for 25% of time
    local warmup_end=$((start_time + DURATION / 4))
    while [ $(date +%s) -lt $warmup_end ]; do
        make_request "$DASHBOARD_URL" "Dashboard" &
        ((total_requests++))
        sleep 1
    done

    echo -e "${RED}💥 SPIKE! Sending high traffic burst...${NC}"

    # High traffic spike for 50% of time
    local spike_end=$((start_time + (DURATION * 3 / 4)))
    while [ $(date +%s) -lt $spike_end ]; do
        for i in {1..10}; do
            make_request "$TIME_URL" "Time" &
            make_request "$SYSINFO_URL" "SysInfo" &
            make_request "$WEATHER_URL" "Weather" &
            make_request "$DASHBOARD_URL" "Dashboard" &
        done
        wait
        ((total_requests += 40))

        echo -e "${RED}✓${NC} Spike: ${total_requests} total requests"
        sleep 0.5
    done

    echo -e "${YELLOW}Returning to normal traffic...${NC}"

    # Cool down
    while [ $(date +%s) -lt $end_time ]; do
        make_request "$DASHBOARD_URL" "Dashboard" &
        ((total_requests++))
        sleep 1
    done
}

# Function for burst mode - periodic bursts
run_burst() {
    local burst_count=0

    while [ $(date +%s) -lt $end_time ]; do
        ((burst_count++))
        echo -e "${YELLOW}Burst #${burst_count}${NC}"

        # Send burst
        for i in {1..20}; do
            make_request "$TIME_URL" "Time" &
            make_request "$SYSINFO_URL" "SysInfo" &
            make_request "$WEATHER_URL" "Weather" &
            make_request "$DASHBOARD_URL" "Dashboard" &
        done
        wait
        ((total_requests += 80))

        echo -e "${GREEN}✓${NC} Burst complete: ${total_requests} total"

        # Wait between bursts
        sleep 10
    done
}

# Function for heavy sustained load
run_heavy() {
    echo -e "${RED}Running heavy sustained load...${NC}"

    while [ $(date +%s) -lt $end_time ]; do
        # Send 20 parallel requests
        for i in {1..5}; do
            make_request "$TIME_URL" "Time" &
            make_request "$SYSINFO_URL" "SysInfo" &
            make_request "$WEATHER_URL" "Weather" &
            make_request "$DASHBOARD_URL" "Dashboard" &
        done
        wait

        ((total_requests += 20))

        if [ $((total_requests % 100)) -eq 0 ]; then
            elapsed=$(($(date +%s) - start_time))
            rate=$((total_requests / elapsed))
            echo -e "${GREEN}✓${NC} ${total_requests} requests in ${elapsed}s (~${rate} req/s)"
        fi

        sleep 0.2
    done
}

# Function for stress test - trigger alerts
run_stress() {
    echo -e "${RED}⚠️  STRESS TEST MODE - This will trigger alerts!${NC}"
    sleep 2

    while [ $(date +%s) -lt $end_time ]; do
        # Massive parallel load
        for i in {1..50}; do
            make_request "$TIME_URL" "Time" &
            make_request "$SYSINFO_URL" "SysInfo" &
            make_request "$WEATHER_URL" "Weather" &
            make_request "$DASHBOARD_URL" "Dashboard" &
        done
        # Don't wait for all - create backlog

        ((total_requests += 200))

        elapsed=$(($(date +%s) - start_time))
        rate=$((total_requests / elapsed))
        echo -e "${RED}⚠️${NC} STRESS: ${total_requests} requests (~${rate} req/s) - Elapsed: ${elapsed}s"

        sleep 0.1
    done

    wait # Clean up remaining background jobs
}

# Run the selected mode
case $MODE in
    balanced)
        run_balanced
        ;;
    spike)
        run_spike
        ;;
    burst)
        run_burst
        ;;
    heavy)
        run_heavy
        ;;
    stress)
        run_stress
        ;;
    *)
        echo -e "${RED}Unknown mode: $MODE${NC}"
        show_help
        exit 1
        ;;
esac

# Final statistics
echo ""
echo -e "${GREEN}═══════════════════════════════════════════════${NC}"
echo -e "${GREEN}  Traffic Generation Complete${NC}"
echo -e "${GREEN}═══════════════════════════════════════════════${NC}"
echo -e "Total Requests:     ${total_requests}"
echo -e "Successful:         ${GREEN}${successful_requests}${NC}"
echo -e "Failed:             ${RED}${failed_requests}${NC}"
echo -e "Duration:           ${DURATION}s"
echo -e "Average Rate:       $((total_requests / DURATION)) req/s"
echo -e "${GREEN}═══════════════════════════════════════════════${NC}"
