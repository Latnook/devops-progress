# Scripts Directory

## Secret Generation Scripts

This directory contains scripts to generate strong cryptographic secrets for the microservices environment.

### For Linux / macOS / Git Bash (Windows)

```bash
./generate-secrets.sh
```

**Requirements:**
- OpenSSL (usually pre-installed)
- Bash shell
- For Windows: Git Bash or WSL

### For Windows PowerShell

```powershell
.\generate-secrets.ps1
```

**Requirements:**
- PowerShell 5.0+ (built into Windows 10/11)
- No additional tools needed

## What Gets Generated

Both scripts generate the same strong secrets:

- **API_KEY** - 256-bit (64 hex chars) for service authentication
- **DASHBOARD_SECRET_KEY** - 256-bit Flask session key
- **SYSINFO_SECRET_KEY** - 256-bit Flask session key
- **JWT_SECRET** - 256-bit JWT signing key
- **GRAFANA_ADMIN_PASSWORD** - 192-bit (32 base64 chars) admin password

## Output

Creates a `.env` file in the parent directory (`1-microservices_test/`) with all secrets.

**⚠️ IMPORTANT:** The `.env` file is automatically excluded from git via `.gitignore`. Never commit secrets to version control!

## Security Notes

1. **Strong Randomness**: Uses cryptographically secure random number generators
   - Linux/Mac: OpenSSL's PRNG
   - Windows: .NET's `RNGCryptoServiceProvider`

2. **Secret Rotation**: Regenerate secrets every 90 days for production systems

3. **Backup**: Store a secure backup of your `.env` file in a password manager or secrets vault

4. **Production**: For production deployments, use a secrets management system:
   - AWS Secrets Manager
   - Azure Key Vault
   - Google Cloud Secret Manager
   - HashiCorp Vault
   - Kubernetes Secrets

## Troubleshooting

### Bash Script Won't Run on Windows

**Solution:** Use Git Bash (comes with Git for Windows) or install WSL (Windows Subsystem for Linux)

```bash
# In Git Bash
cd 1-microservices_test/scripts
./generate-secrets.sh
```

### PowerShell Execution Policy Error

**Solution:** Allow script execution temporarily

```powershell
# Run as Administrator
Set-ExecutionPolicy -ExecutionPolicy RemoteSigned -Scope CurrentUser

# Then run the script
.\generate-secrets.ps1

# Optionally restore policy
Set-ExecutionPolicy -ExecutionPolicy Restricted -Scope CurrentUser
```

### Permission Denied

**Linux/Mac:**
```bash
chmod +x generate-secrets.sh
./generate-secrets.sh
```

## Example Usage

```bash
# Linux / Mac / Git Bash
cd 1-microservices_test/scripts
./generate-secrets.sh

# Windows PowerShell
cd 1-microservices_test\scripts
.\generate-secrets.ps1

# Check generated secrets (DON'T share this output!)
cat ../.env  # Linux/Mac/Git Bash
type ..\.env  # Windows PowerShell

# Start services with new secrets
cd ..
docker-compose up --build
```
