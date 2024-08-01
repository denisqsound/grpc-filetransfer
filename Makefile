VERSION    ?= $(shell git rev-parse --short HEAD)
DOCKER_TAG ?= denisqsound/grpc-filetransfer:$(VERSION)

IMAGE_NAME ?= denisqsound/grpc-filetransfer:test

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

build:
	mkdir -p $(DIST_PATH)
	CGO_ENABLED=0 go build -ldflags="-s -w" -o $(DIST_PATH)/server ./cmd/server

docker-build:
	docker build -t $(IMAGE_NAME) .

docker-run:
	docker run --network host -p 81:81 $(IMAGE_NAME)

docker-publish:
	docker tag $(IMAGE_NAME) $(DOCKER_TAG)
	docker push $(IMAGE_NAME)

#================================================================================================

clean:
	rm -f 8GB.bin