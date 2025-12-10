FROM python:3.11-slim

# Create non-root user for security
RUN groupadd -r appuser && useradd -r -g appuser appuser

WORKDIR /app

# Copy and install dependencies
COPY requirements.txt .
RUN pip install --no-cache-dir --upgrade pip && \
    pip install --no-cache-dir -r requirements.txt

# Copy application code
COPY app.py .

# Change ownership to non-root user
RUN chown -R appuser:appuser /app

# Switch to non-root user
USER appuser

EXPOSE 5000

# Use Gunicorn production server instead of Flask dev server
# --bind 0.0.0.0:5000 - Bind to all interfaces on port 5000
# --workers 4 - Use 4 worker processes for handling requests
# --threads 2 - Each worker uses 2 threads
# --timeout 30 - Request timeout of 30 seconds
# --access-logfile - - Log access to stdout
# --error-logfile - - Log errors to stdout
CMD ["gunicorn", "--bind", "0.0.0.0:5000", "--workers", "4", "--threads", "2", "--timeout", "30", "--access-logfile", "-", "--error-logfile", "-", "app:app"]
