package router

import (
	"testing"

	"github.com/google/go-cmp/cmp"

	"github.com/go-chi/chi"
)

func TestBuilder(t *testing.T) {
	tests := []struct {
		name string
		in   *Injected
		out  chi.Router
	}{
		{
			"nil returns nil",
			nil,
			nil,
		},
	}

	for _, tt := range tests {
		tt := tt
		t.Run(tt.name, func(t *testing.T) {
			ret := Builder(tt.in)
			if diff := cmp.Diff(ret, tt.out); diff != "" {
				t.Errorf("differs: (-got +want)\n%s", diff)
			}
		})
	}
}
