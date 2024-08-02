# Use the official Golang image as the base image
FROM golang:1.20-alpine AS builder

WORKDIR /app
COPY go.mod go.sum ./
RUN go mod download
COPY . .

RUN go build -o /app/bin/client ./cmd/client
RUN go build -o /app/bin/generator ./cmd/generator

FROM alpine:latest
WORKDIR /root/

COPY --from=builder /app/bin/client .
COPY --from=builder /app/bin/generator .

CMD sh -c "./generator && sleep infinity"