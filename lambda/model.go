package main

type Person struct {
	ID       string   `json:"Id"`
	Name     string   `json:"Name,omitempty"`
	Pictures []string `json:"Pictures,omitempty"`
	Sub      string   `json:"Sub"`
}
