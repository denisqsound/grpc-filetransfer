# Use the official Golang image as the base image
FROM golang:1.20-alpine AS builder

WORKDIR /app
COPY go.mod go.sum ./
RUN go mod download
COPY . .

RUN go build -o /app/bin/server ./cmd/server

FROM alpine:latest
WORKDIR /root/
COPY --from=builder /app/bin/server .
COPY config/server/config.yml config.yml
EXPOSE 81
CMD ["./server"]