provider "google" {
    credentials = "${file("../gold-braid-268003-730142342060.json")}"
    project     = "gold-braid-268003"
    region      = "us-west1"
}
