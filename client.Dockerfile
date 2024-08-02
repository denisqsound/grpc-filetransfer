FROM golang:1.22-alpine AS builder

WORKDIR /app
COPY go.mod go.sum ./
RUN go mod download
COPY . .

RUN go build -ldflags="-s -w" -o /app/bin/client ./cmd/client
RUN go build -ldflags="-s -w" -o /app/bin/generator ./cmd/generator

FROM alpine:latest
RUN apk update && apk add --no-cache grpc && apk add curl && apk add --no-cache --repository=http://dl-cdn.alpinelinux.org/alpine/edge/testing grpcurl
WORKDIR /root/

COPY --from=builder /app/bin/client .
COPY --from=builder /app/bin/generator .

CMD sh -c "./generator && sleep infinity"