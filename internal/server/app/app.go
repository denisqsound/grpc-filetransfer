package app

import (
	"context"
	"net"
	"os"
	"os/signal"
	"syscall"

	"google.golang.org/grpc"
	"google.golang.org/grpc/reflection"

	"github.com/denisqosund/grpc-filetransfer/internal/server/service"
	"github.com/denisqosund/grpc-filetransfer/pkg/logger"

	config "github.com/denisqosund/grpc-filetransfer/config/server"
	uploadpb "github.com/denisqosund/grpc-filetransfer/pkg/proto"
)

// Run creates objects via constructors.
func Run(cfg *config.Config) {
	log := logger.New(cfg.Log.Level)
	log.Debug("App started")
	ctx, cancel := context.WithCancel(context.Background())
	defer cancel()

	serverRegistrar := grpc.NewServer()

	reflection.Register(serverRegistrar)
	uploadServer := service.New(log, cfg)

	uploadpb.RegisterFileServiceServer(serverRegistrar, uploadServer)

	listen, err := net.Listen("tcp", cfg.GRPC.Port)
	if err != nil {
		log.Fatal(err)
	}
	interrupt := make(chan os.Signal, 1)
	shutdownSignals := []os.Signal{
		os.Interrupt,
		syscall.SIGTERM,
		syscall.SIGINT,
		syscall.SIGQUIT,
	}
	signal.Notify(interrupt, shutdownSignals...)
	go func(g *grpc.Server) {
		log.Info("setGRPC - gRPC server started on " + cfg.GRPC.Port)
		if err := g.Serve(listen); err != nil {
			log.Fatal(err)
		}
	}(serverRegistrar)
	select {
	case killSignal := <-interrupt:
		log.Debug("Got ", killSignal)
		cancel()
	case <-ctx.Done():
	}
}
