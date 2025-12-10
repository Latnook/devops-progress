# PowerShell script to generate strong secrets for the microservices environment
# This script generates cryptographically secure random secrets for:
# - API keys
# - Flask secret keys
# - Grafana admin password

Write-Host "🔐 Security Secrets Generator" -ForegroundColor Cyan
Write-Host "==============================`n" -ForegroundColor Cyan

# Check if .env file already exists
if (Test-Path "../.env") {
    Write-Host "⚠️  WARNING: .env file already exists!" -ForegroundColor Yellow
    $response = Read-Host "Do you want to overwrite it? (y/N)"
    if ($response -notmatch '^[Yy]$') {
        Write-Host "❌ Aborted. Existing .env file preserved." -ForegroundColor Red
        exit 1
    }
}

Write-Host "Generating secure random secrets...`n"

# Generate random bytes and convert to hex
function Get-RandomHex {
    param([int]$ByteCount)
    $bytes = New-Object byte[] $ByteCount
    $rng = [System.Security.Cryptography.RNGCryptoServiceProvider]::new()
    $rng.GetBytes($bytes)
    return ($bytes | ForEach-Object { $_.ToString("x2") }) -join ''
}

# Generate random base64 string
function Get-RandomBase64 {
    param([int]$ByteCount)
    $bytes = New-Object byte[] $ByteCount
    $rng = [System.Security.Cryptography.RNGCryptoServiceProvider]::new()
    $rng.GetBytes($bytes)
    return [Convert]::ToBase64String($bytes)
}

# Generate API key (64 characters hex = 32 bytes)
$API_KEY = Get-RandomHex -ByteCount 32

# Generate dashboard secret key (64 characters hex)
$DASHBOARD_SECRET = Get-RandomHex -ByteCount 32

# Generate sysinfo secret key (64 characters hex)
$SYSINFO_SECRET = Get-RandomHex -ByteCount 32

# Generate JWT secret (64 characters hex)
$JWT_SECRET = Get-RandomHex -ByteCount 32

# Generate Grafana admin password (24 bytes base64 = 32 chars)
$GRAFANA_PASSWORD = Get-RandomBase64 -ByteCount 24

# Get current date
$currentDate = Get-Date -Format "yyyy-MM-dd HH:mm:ss"

# Create .env file
$envContent = @"
# Security Configuration - Generated $currentDate
# DO NOT commit this file to version control!

# API Keys for service-to-service authentication
# This key must be included in X-API-Key header for all API requests
API_KEY=$API_KEY

# Grafana Admin Credentials
GRAFANA_ADMIN_USER=admin
GRAFANA_ADMIN_PASSWORD=$GRAFANA_PASSWORD

# JWT Configuration
JWT_SECRET=$JWT_SECRET

# Flask Secret Keys
DASHBOARD_SECRET_KEY=$DASHBOARD_SECRET
SYSINFO_SECRET_KEY=$SYSINFO_SECRET

# Production/Development Mode
FLASK_ENV=production
NODE_ENV=production

# HTTPS Configuration (set to True when TLS is enabled)
HTTPS_ENABLED=False

# Rate Limiting Configuration
RATE_LIMIT_ENABLED=True
REDIS_URL=memory://
"@

# Write to file
$envContent | Out-File -FilePath "../.env" -Encoding UTF8 -NoNewline

Write-Host "✅ Secrets generated successfully!`n" -ForegroundColor Green

Write-Host "📝 Configuration Summary:" -ForegroundColor Cyan
Write-Host "========================"
Write-Host "API Key: $($API_KEY.Substring(0,16))... (64 chars)"
Write-Host "Dashboard Secret: $($DASHBOARD_SECRET.Substring(0,16))... (64 chars)"
Write-Host "Sysinfo Secret: $($SYSINFO_SECRET.Substring(0,16))... (64 chars)"
Write-Host "JWT Secret: $($JWT_SECRET.Substring(0,16))... (64 chars)"
Write-Host "Grafana Password: $($GRAFANA_PASSWORD.Substring(0,8))... (32 chars)`n"

Write-Host "🔒 Security Notes:" -ForegroundColor Yellow
Write-Host "=================="
Write-Host "1. Secrets saved to .env file"
Write-Host "2. NEVER commit .env file to version control"
Write-Host "3. Keep backups of .env file in a secure location"
Write-Host "4. Rotate secrets regularly (every 90 days recommended)"
Write-Host "5. Use environment variables or secrets management in production`n"

Write-Host "🚀 Next Steps:" -ForegroundColor Cyan
Write-Host "=============="
Write-Host "1. Review the generated .env file"
Write-Host "2. Start services with: docker-compose up --build"
Write-Host "3. Access dashboard at: http://localhost:5000"
Write-Host "4. Access Grafana at: http://localhost:3000"
Write-Host "   - Username: admin"
Write-Host "   - Password: (check .env file)`n"
