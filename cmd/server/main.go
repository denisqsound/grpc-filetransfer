package main

import (
	"log"

	config "github.com/denisqosund/grpc-filetransfer/config/server"
	"github.com/denisqosund/grpc-filetransfer/internal/server/app"
)

func main() {
	cfg, err := config.NewConfig()
	if err != nil {
		log.Fatalf("Config error: %s", err)
	}
	log.Println("config: ", cfg)
	app.Run(cfg)
}
