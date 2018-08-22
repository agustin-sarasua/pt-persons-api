package main

type Person struct {
	ID       string   `json:"id"`
	Name     string   `json:"name,omitempty"`
	Pictures []string `json:"pictures,omitempty"`
	Sub      string   `json:"sub"`
}
