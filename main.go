package main

import "fmt"

var (
	// Version is ...
	Version string
	// Revision is ...
	Revision string
	// BuildTime is ...
	BuildTime string
)

func main() {
	fmt.Printf("version %s, revision %s, buildTime %s", Version, Revision, BuildTime)
}
