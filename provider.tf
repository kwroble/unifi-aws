provider "google" {
  credentials = file("${path.module}/prod-svc-creds.json")
  project     = var.project
  region      = var.region
  zone        = var.zone
}