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

# Balanced mode
function Start-BalancedTraffic {
    $sleepMs = [int](1000 / $Rate)

    while ((Get-Date) -lt $script:endTime) {
        # Make requests to all services
        $jobs = @(
            Start-Job -ScriptBlock { param($url) Invoke-WebRequest -Uri $url -Method Get -TimeoutSec 5 -UseBasicParsing } -ArgumentList $TIME_URL
            Start-Job -ScriptBlock { param($url) Invoke-WebRequest -Uri $url -Method Get -TimeoutSec 5 -UseBasicParsing } -ArgumentList $SYSINFO_URL
            Start-Job -ScriptBlock { param($url) Invoke-WebRequest -Uri $url -Method Get -TimeoutSec 5 -UseBasicParsing } -ArgumentList $WEATHER_URL
            Start-Job -ScriptBlock { param($url) Invoke-WebRequest -Uri $url -Method Get -TimeoutSec 5 -UseBasicParsing } -ArgumentList $DASHBOARD_URL
        )

        $jobs | Wait-Job -Timeout 10 | Out-Null
        $script:totalRequests += 4

        $jobs | ForEach-Object {
            if ($_.State -eq 'Completed') {
                $script:successfulRequests++
            } else {
                $script:failedRequests++
            }
            Remove-Job $_
        }

        # Progress update
        if ($script:totalRequests % 40 -eq 0) {
            $elapsed = ((Get-Date) - $script:startTime).TotalSeconds
            Write-Host "✓ Sent $($script:totalRequests) requests in $([int]$elapsed)s (Success: $($script:successfulRequests), Failed: $($script:failedRequests))" -ForegroundColor Green
        }

        Start-Sleep -Milliseconds $sleepMs
    }
}

# Spike mode
function Start-SpikeTraffic {
    Write-Host "Starting with low traffic..." -ForegroundColor Yellow

    # Low traffic for 25% of time
    $warmupEnd = $script:startTime.AddSeconds($Duration / 4)
    while ((Get-Date) -lt $warmupEnd) {
        Invoke-ServiceRequest $DASHBOARD_URL | Out-Null
        $script:totalRequests++
        Start-Sleep -Seconds 1
    }

    Write-Host "💥 SPIKE! Sending high traffic burst..." -ForegroundColor Red

    # High traffic spike
    $spikeEnd = $script:startTime.AddSeconds($Duration * 3 / 4)
    while ((Get-Date) -lt $spikeEnd) {
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
        Start-Sleep -Milliseconds 500
    }

    Write-Host "Returning to normal traffic..." -ForegroundColor Yellow

    # Cool down
    while ((Get-Date) -lt $script:endTime) {
        Invoke-ServiceRequest $DASHBOARD_URL | Out-Null
        $script:totalRequests++
        Start-Sleep -Seconds 1
    }
}

# Burst mode
function Start-BurstTraffic {
    $burstCount = 0

    while ((Get-Date) -lt $script:endTime) {
        $burstCount++
        Write-Host "Burst #$burstCount" -ForegroundColor Yellow

        # Send burst
        1..20 | ForEach-Object {
            Invoke-ServiceRequest $TIME_URL | Out-Null
            Invoke-ServiceRequest $SYSINFO_URL | Out-Null
            Invoke-ServiceRequest $WEATHER_URL | Out-Null
            Invoke-ServiceRequest $DASHBOARD_URL | Out-Null
        }
        $script:totalRequests += 80

        Write-Host "✓ Burst complete: $($script:totalRequests) total" -ForegroundColor Green

        # Wait between bursts
        Start-Sleep -Seconds 10
    }
}

# Heavy mode
function Start-HeavyTraffic {
    Write-Host "Running heavy sustained load..." -ForegroundColor Red

    while ((Get-Date) -lt $script:endTime) {
        # Send 20 parallel requests
        1..5 | ForEach-Object {
            Invoke-ServiceRequest $TIME_URL | Out-Null
            Invoke-ServiceRequest $SYSINFO_URL | Out-Null
            Invoke-ServiceRequest $WEATHER_URL | Out-Null
            Invoke-ServiceRequest $DASHBOARD_URL | Out-Null
        }

        $script:totalRequests += 20

        if ($script:totalRequests % 100 -eq 0) {
            $elapsed = ((Get-Date) - $script:startTime).TotalSeconds
            $rate = [int]($script:totalRequests / $elapsed)
            Write-Host "✓ $($script:totalRequests) requests in $([int]$elapsed)s (~$rate req/s)" -ForegroundColor Green
        }

        Start-Sleep -Milliseconds 200
    }
}

# Run selected mode
switch ($Mode.ToLower()) {
    "balanced" { Start-BalancedTraffic }
    "spike" { Start-SpikeTraffic }
    "burst" { Start-BurstTraffic }
    "heavy" { Start-HeavyTraffic }
    default {
        Write-Host "Unknown mode: $Mode" -ForegroundColor Red
        Show-Help
        exit 1
    }
}

# Final statistics
$totalDuration = ((Get-Date) - $startTime).TotalSeconds
Write-Host ""
Write-Host "===============================================" -ForegroundColor Green
Write-Host "  Traffic Generation Complete" -ForegroundColor Green
Write-Host "===============================================" -ForegroundColor Green
Write-Host "Total Requests:     $totalRequests"
Write-Host "Successful:         $successfulRequests" -ForegroundColor Green
Write-Host "Failed:             $failedRequests" -ForegroundColor Red
Write-Host "Duration:           $([int]$totalDuration)s"
Write-Host "Average Rate:       $([int]($totalRequests / $totalDuration)) req/s"
Write-Host "===============================================" -ForegroundColor Green
