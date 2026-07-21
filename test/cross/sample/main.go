package main

/*
#include <unistd.h>
static long my_pid(void) { return (long)getpid(); }
*/
import "C"

import (
	"fmt"
	"net/http"
	"os"
	"time"
)

// A cgo + TLS app cross-built by the -cross toolchain: proves cgo links 10.9-safe AND the
// keychain-union trust model (baked into std) verifies a modern chain on the target 10.9 box.
func main() {
	fmt.Printf("cross ok pid=%d\n", int64(C.my_pid()))
	c := &http.Client{Timeout: 20 * time.Second}
	resp, err := c.Get("https://valid-isrgrootx2.letsencrypt.org/")
	if err != nil {
		fmt.Println("TLS REJECTED:", err)
		os.Exit(1)
	}
	resp.Body.Close()
	fmt.Println("VERIFIED:", resp.Status)
}
