VERSION    ?= $(shell git rev-parse --short HEAD)

DOCKER_SERVER_TAG ?= denisqsound/grpc-filetransfer-server:$(VERSION)
DOCKER_CLIENT_TAG ?= denisqsound/grpc-filetransfer-client:$(VERSION)

IMAGE_SERVER_NAME ?= denisqsound/grpc-filetransfer-server:test

HOST ?= 127.0.0.1
PORT ?= 81

DIST_PATH  	  ?= dist

.PHONY: build


#================================================================================================
run-server:
	go run cmd/server/main.go

run-data:
	go run cmd/generator/main.go

run-client:
	go run cmd/client/main.go -a=':81' -f=8GB.bin

#================================================================================================

# Server

build-server:
	mkdir -p $(DIST_PATH)
	CGO_ENABLED=0 go build -ldflags="-s -w" -o $(DIST_PATH)/server ./cmd/server

docker-build-server:
	docker build -f server.Dockerfile -t $(IMAGE_SERVER_NAME)  .

docker-run-server:
	docker run --network host -p 81:81 $(IMAGE_SERVER_NAME)

docker-publish-server:
	docker tag $(IMAGE_SERVER_NAME) $(DOCKER_SERVER_TAG)
	docker push $(DOCKER_SERVER_TAG)

#================================================================================================

# Client

build-client:
	mkdir -p $(DIST_PATH)
	CGO_ENABLED=0 go build -ldflags="-s -w" -o $(DIST_PATH)/client ./cmd/client
	go build -o $(DIST_PATH)/generator ./cmd/generator

docker-build-client:
	docker build -f client.Dockerfile -t $(DOCKER_CLIENT_TAG)  .

docker-run-client:
	docker run --network host -it $(DOCKER_CLIENT_TAG) sh

docker-publish-client:
	docker tag $(DOCKER_CLIENT_TAG) $(DOCKER_CLIENT_TAG)
	docker push $(DOCKER_CLIENT_TAG)

#================================================================================================

clean:
	rm -f 8GB.bin

generate:
	protoc --go_out=pkg/proto --go-grpc_out=pkg/proto pkg/proto/upload.proto