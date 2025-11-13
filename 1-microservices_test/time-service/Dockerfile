# Build stage
FROM golang:1.21-alpine AS builder

WORKDIR /app

COPY go.mod ./
RUN go mod download

COPY main.go ./
RUN go build -o time-service main.go

# Runtime stage
FROM alpine:latest

WORKDIR /app

COPY --from=builder /app/time-service .

EXPOSE 5001

CMD ["./time-service"]
