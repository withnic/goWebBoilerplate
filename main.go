package main

import (
	"log"
	"net/http"

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
				"error", err,
			)
		}
	})

	if err := http.ListenAndServe(":8080", router); err != nil {
		logger.Sugar().Errorw("failed to serve",
			"err", err,
		)
	}
}
