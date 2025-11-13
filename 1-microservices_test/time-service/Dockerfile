# Build stage
FROM golang:1.21-alpine AS builder

WORKDIR /app

COPY go.mod ./
COPY main.go ./
RUN go mod tidy && go mod download

RUN go build -o time-service main.go

# Runtime stage
FROM alpine:latest

WORKDIR /app

COPY --from=builder /app/time-service .

EXPOSE 5001

CMD ["./time-service"]
