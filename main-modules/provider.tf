provider "google" {
    credentials = "${file("~/Documents/Mehul/Vasten_Cloud/vasten_terraform/gold-braid-268003-a960129a6874.json")}"
    project     = "gold-braid-268003"
    region      = "us-west1"
}
