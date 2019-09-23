package main

import (
	"context"
	"log"
	"net/http"
	"os"
	"os/signal"
	"syscall"
	"time"

	"go.uber.org/zap"

	"github.com/go-chi/chi"
	"github.com/unrolled/render"
)

var (
	// Version is ...
	Version string
	// Revision is ...
	Revision string
	// BuildTime is ...
	BuildTime string
)

func main() {
	router := chi.NewRouter()
	r := render.New()
	logger, err := zap.NewProduction()
	if err != nil {
		log.Fatal("failed to New zap")
	}
	defer func() {
		if err := logger.Sync(); err != nil {
			log.Printf("failed to logger.Sync %v", err)
		}
	}()

	router.Get("/", func(writer http.ResponseWriter, request *http.Request) {
		if err := r.JSON(writer, http.StatusOK, map[string]interface{}{
			"version":   Version,
			"revision":  Revision,
			"buildTime": BuildTime,
		}); err != nil {
			logger.Sugar().Errorw("failed to render json",
				"url", request.URL,
				"error", err.Error(),
			)
		}
	})

	srv := &http.Server{
		Addr:    ":8080",
		Handler: router,
	}

	go func() {
		logger.Sugar().Infow("Listening",
			"addr", srv.Addr)
		if err := srv.ListenAndServe(); err != nil {
			logger.Sugar().Errorw("failed to serve",
				"error", err.Error(),
			)
		}
	}()

	quit := make(chan os.Signal, 1)
	// https://docs.docker.com/engine/reference/commandline/stop/
	signal.Notify(quit, syscall.SIGTERM, os.Interrupt)
	logger.Sugar().Infof("SIGNAL %d received, then shutting down...", <-quit)
	ctx, cancel := context.WithTimeout(context.Background(), 10*time.Second)
	defer cancel()
	if err := srv.Shutdown(ctx); err != nil {
		// Error from closing listeners, or context timeout:
		logger.Sugar().Errorw("Failed to gracefully shutdown",
			"error", err.Error())
	}
	logger.Sugar().Info("Server shutdown")
}
