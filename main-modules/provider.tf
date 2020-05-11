provider "google" {
    credentials = "${file("../unique-badge-276520-3cc06295e54b.json")}"
    project     = "unique-badge-276520"
    region      = "us-west1"
}
