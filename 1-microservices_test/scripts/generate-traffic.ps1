# Traffic Generation Script for Microservices (PowerShell/Windows)
# Generates realistic load patterns to populate monitoring dashboards

param(
    [int]$Duration = 60,          # Duration in seconds
    [int]$Rate = 5,                # Requests per second
    [string]$Mode = "balanced"     # Traffic pattern mode
)

# URLs
$DASHBOARD_URL = "http://localhost:5000"
$TIME_URL = "http://localhost:5001/api/time"
$SYSINFO_URL = "http://localhost:5002/api/sysinfo"
$WEATHER_URL = "http://localhost:5003/api/weather"

# Help message
function Show-Help {
    Write-Host @"
Usage: .\generate-traffic.ps1 [-Duration SECONDS] [-Rate RPS] [-Mode MODE]

Generate traffic to microservices for monitoring and testing.

OPTIONS:
    -Duration SECONDS    Duration to run traffic (default: 60)
    -Rate RPS           Requests per second (default: 5)
    -Mode MODE          Traffic pattern mode (default: balanced)
                        Modes:
                          balanced  - Equal load across all services
                          spike     - Sudden traffic spike
                          burst     - Periodic bursts
                          heavy     - High sustained load

EXAMPLES:
    # Generate balanced traffic for 2 minutes
    .\generate-traffic.ps1 -Duration 120 -Rate 10

    # Create traffic spike
    .\generate-traffic.ps1 -Mode spike -Rate 50

    # Heavy load test
    .\generate-traffic.ps1 -Mode heavy -Duration 300 -Rate 20

"@
}

# Show header
Write-Host "===============================================" -ForegroundColor Green
Write-Host "  Microservices Traffic Generator (Windows)" -ForegroundColor Green
Write-Host "===============================================" -ForegroundColor Green
Write-Host "Mode:          $Mode" -ForegroundColor Yellow
Write-Host "Duration:      ${Duration}s" -ForegroundColor Yellow
Write-Host "Rate:          $Rate req/s" -ForegroundColor Yellow
Write-Host "===============================================" -ForegroundColor Green
Write-Host ""

# Counters
$totalRequests = 0
$successfulRequests = 0
$failedRequests = 0
$startTime = Get-Date
$endTime = $startTime.AddSeconds($Duration)

# Function to make a request
function Invoke-ServiceRequest {
    param([string]$url)

    try {
        $response = Invoke-WebRequest -Uri $url -Method Get -TimeoutSec 5 -UseBasicParsing
        if ($response.StatusCode -eq 200) {
            return $true
        }
    } catch {
        return $false
    }
    return $false
}

# Balanced mode - Equal load distribution across all services
function Start-BalancedTraffic {
    # Calculate sleep duration between requests to achieve target rate
    $sleepMs = [int](1000 / $Rate)

    while ((Get-Date) -lt $script:endTime) {
        # Make parallel requests to all services using PowerShell jobs
        # Jobs run in background threads for concurrent execution
        $jobs = @(
            Start-Job -ScriptBlock { param($url) Invoke-WebRequest -Uri $url -Method Get -TimeoutSec 5 -UseBasicParsing } -ArgumentList $TIME_URL
            Start-Job -ScriptBlock { param($url) Invoke-WebRequest -Uri $url -Method Get -TimeoutSec 5 -UseBasicParsing } -ArgumentList $SYSINFO_URL
            Start-Job -ScriptBlock { param($url) Invoke-WebRequest -Uri $url -Method Get -TimeoutSec 5 -UseBasicParsing } -ArgumentList $WEATHER_URL
            Start-Job -ScriptBlock { param($url) Invoke-WebRequest -Uri $url -Method Get -TimeoutSec 5 -UseBasicParsing } -ArgumentList $DASHBOARD_URL
        )

        # Wait for all jobs to complete (with 10 second timeout)
        $jobs | Wait-Job -Timeout 10 | Out-Null
        $script:totalRequests += 4

        # Check job completion status and update counters
        $jobs | ForEach-Object {
            if ($_.State -eq 'Completed') {
                $script:successfulRequests++
            } else {
                # Job failed or timed out
                $script:failedRequests++
            }
            # Clean up completed job to free memory
            Remove-Job $_
        }

        # Progress update every 40 requests (10 cycles of 4 requests each)
        if ($script:totalRequests % 40 -eq 0) {
            $elapsed = ((Get-Date) - $script:startTime).TotalSeconds
            Write-Host "✓ Sent $($script:totalRequests) requests in $([int]$elapsed)s (Success: $($script:successfulRequests), Failed: $($script:failedRequests))" -ForegroundColor Green
        }

        # Throttle requests to maintain target rate
        Start-Sleep -Milliseconds $sleepMs
    }
}

# Spike mode - Simulates sudden traffic spike (useful for testing autoscaling/alerting)
function Start-SpikeTraffic {
    Write-Host "Starting with low traffic..." -ForegroundColor Yellow

    # Phase 1: Warmup - Low traffic for first 25% of duration (1 req/sec)
    $warmupEnd = $script:startTime.AddSeconds($Duration / 4)
    while ((Get-Date) -lt $warmupEnd) {
        Invoke-ServiceRequest $DASHBOARD_URL | Out-Null
        $script:totalRequests++
        Start-Sleep -Seconds 1
    }

    Write-Host "💥 SPIKE! Sending high traffic burst..." -ForegroundColor Red

    # Phase 2: Spike - High traffic burst for middle 50% of duration
    # Simulates sudden load increase (10x normal traffic)
    $spikeEnd = $script:startTime.AddSeconds($Duration * 3 / 4)
    while ((Get-Date) -lt $spikeEnd) {
        # Send 10 batches of 4 requests each (40 requests total per iteration)
        1..10 | ForEach-Object {
            $jobs = @(
                Start-Job -ScriptBlock { param($url) Invoke-WebRequest -Uri $url -Method Get -TimeoutSec 5 -UseBasicParsing } -ArgumentList $TIME_URL
                Start-Job -ScriptBlock { param($url) Invoke-WebRequest -Uri $url -Method Get -TimeoutSec 5 -UseBasicParsing } -ArgumentList $SYSINFO_URL
                Start-Job -ScriptBlock { param($url) Invoke-WebRequest -Uri $url -Method Get -TimeoutSec 5 -UseBasicParsing } -ArgumentList $WEATHER_URL
                Start-Job -ScriptBlock { param($url) Invoke-WebRequest -Uri $url -Method Get -TimeoutSec 5 -UseBasicParsing } -ArgumentList $DASHBOARD_URL
            )
            $script:totalRequests += 4
        }

        Write-Host "✓ Spike: $($script:totalRequests) total requests" -ForegroundColor Red
        # Brief pause between spike bursts
        Start-Sleep -Milliseconds 500
    }

    Write-Host "Returning to normal traffic..." -ForegroundColor Yellow

    # Phase 3: Cooldown - Return to low traffic for final 25% of duration
    while ((Get-Date) -lt $script:endTime) {
        Invoke-ServiceRequest $DASHBOARD_URL | Out-Null
        $script:totalRequests++
        Start-Sleep -Seconds 1
    }
}

# Burst mode - Periodic traffic bursts with quiet periods (simulates batch processing patterns)
function Start-BurstTraffic {
    $burstCount = 0

    while ((Get-Date) -lt $script:endTime) {
        $burstCount++
        Write-Host "Burst #$burstCount" -ForegroundColor Yellow

        # Send a burst of 80 requests (20 iterations × 4 services each)
        # Simulates periodic batch job or cron task hitting services
        1..20 | ForEach-Object {
            Invoke-ServiceRequest $TIME_URL | Out-Null
            Invoke-ServiceRequest $SYSINFO_URL | Out-Null
            Invoke-ServiceRequest $WEATHER_URL | Out-Null
            Invoke-ServiceRequest $DASHBOARD_URL | Out-Null
        }
        $script:totalRequests += 80

        Write-Host "✓ Burst complete: $($script:totalRequests) total" -ForegroundColor Green

        # Wait 10 seconds between bursts (simulates quiet period)
        # This creates a sawtooth pattern in monitoring graphs
        Start-Sleep -Seconds 10
    }
}

# Heavy mode - Sustained high load for stress testing
function Start-HeavyTraffic {
    Write-Host "Running heavy sustained load..." -ForegroundColor Red

    while ((Get-Date) -lt $script:endTime) {
        # Send 20 requests per iteration (5 batches × 4 services)
        # Maintains high sustained load to test service capacity
        1..5 | ForEach-Object {
            Invoke-ServiceRequest $TIME_URL | Out-Null
            Invoke-ServiceRequest $SYSINFO_URL | Out-Null
            Invoke-ServiceRequest $WEATHER_URL | Out-Null
            Invoke-ServiceRequest $DASHBOARD_URL | Out-Null
        }

        $script:totalRequests += 20

        # Progress report every 100 requests
        if ($script:totalRequests % 100 -eq 0) {
            $elapsed = ((Get-Date) - $script:startTime).TotalSeconds
            $rate = [int]($script:totalRequests / $elapsed)
            Write-Host "✓ $($script:totalRequests) requests in $([int]$elapsed)s (~$rate req/s)" -ForegroundColor Green
        }

        # Small delay to prevent overwhelming the system (200ms = ~100 req/s)
        Start-Sleep -Milliseconds 200
    }
}

# ============================================================================
# Mode Execution
# ============================================================================
# Execute the selected traffic pattern mode
switch ($Mode.ToLower()) {
    "balanced" { Start-BalancedTraffic }  # Equal load distribution
    "spike" { Start-SpikeTraffic }        # Sudden traffic spike pattern
    "burst" { Start-BurstTraffic }        # Periodic burst pattern
    "heavy" { Start-HeavyTraffic }        # Sustained high load
    default {
        # Unknown mode - show help and exit
        Write-Host "Unknown mode: $Mode" -ForegroundColor Red
        Show-Help
        exit 1
    }
}

# ============================================================================
# Final Statistics Report
# ============================================================================
# Calculate and display comprehensive traffic generation statistics
$totalDuration = ((Get-Date) - $startTime).TotalSeconds
Write-Host ""
Write-Host "===============================================" -ForegroundColor Green
Write-Host "  Traffic Generation Complete" -ForegroundColor Green
Write-Host "===============================================" -ForegroundColor Green
Write-Host "Total Requests:     $totalRequests"
Write-Host "Successful:         $successfulRequests" -ForegroundColor Green
Write-Host "Failed:             $failedRequests" -ForegroundColor Red
Write-Host "Duration:           $([int]$totalDuration)s"
# Calculate average request rate (requests per second)
Write-Host "Average Rate:       $([int]($totalRequests / $totalDuration)) req/s"
Write-Host "===============================================" -ForegroundColor Green
