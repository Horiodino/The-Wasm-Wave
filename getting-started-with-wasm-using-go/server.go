package main

import (
	"log"
	"net/http"
)

const (
	Address string = ":8090"
	TempDir string = "."
)

func main() {

	fileServer := http.FileServer(http.Dir(TempDir))

	if err := http.ListenAndServe(Address, fileServer); err != nil {
		log.Fatal(err)
	}
}
