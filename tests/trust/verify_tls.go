package main

import (
	"fmt"
	"net/http"
	"os"
	"time"
)

// Usage: verify_tls [url]
// Default target chains to ISRG Root X1. Let's Encrypt's pinned endpoints
// valid-isrgrootx1/x2.letsencrypt.org chain to exactly one root, which makes
// them deterministic distrust targets regardless of CA-hierarchy churn.
func main() {
	url := "https://valid-isrgrootx1.letsencrypt.org/"
	if len(os.Args) > 1 {
		url = os.Args[1]
	}
	c := &http.Client{Timeout: 20 * time.Second}
	resp, err := c.Get(url)
	if err != nil {
		fmt.Println("REJECTED:", err)
		os.Exit(1)
	}
	resp.Body.Close()
	fmt.Println("VERIFIED:", resp.Status)
}
