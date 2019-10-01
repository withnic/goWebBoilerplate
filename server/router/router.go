// Package router implements router functions.
package router

import (
	"net/http"

	"github.com/unrolled/render"

	"go.uber.org/zap"

	"github.com/go-chi/chi"
)

// Injected represents injected params for Builder.
type Injected struct {
	Logger    *zap.Logger
	Render    *render.Render
	Version   string
	Revision  string
	BuildTime string
}

// Builder returns chi.Router.
func Builder(i *Injected) chi.Router {
	if i == nil {
		return nil
	}
	router := chi.NewRouter()

	router.Get("/", func(writer http.ResponseWriter, request *http.Request) {
		if err := i.Render.JSON(writer, http.StatusOK, map[string]interface{}{
			"version":   i.Version,
			"revision":  i.Revision,
			"buildTime": i.BuildTime,
		}); err != nil {
			i.Logger.Sugar().Errorw("failed to render json",
				"url", request.URL,
				"error", err.Error(),
			)
		}
	})

	return router
}
