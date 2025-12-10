# Build stage
FROM golang:1.21-alpine AS builder

WORKDIR /app

COPY go.mod ./
COPY main.go ./
RUN go mod tidy && go mod download

RUN go build -o time-service main.go

# Runtime stage
FROM alpine:latest

# Create non-root user for security
RUN addgroup -S appuser && adduser -S appuser -G appuser

WORKDIR /app

# Copy binary from builder stage
COPY --from=builder /app/time-service .

# Change ownership to non-root user
RUN chown appuser:appuser time-service

# Switch to non-root user
USER appuser

EXPOSE 5001

CMD ["./time-service"]
