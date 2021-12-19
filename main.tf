resource "google_compute_address" "external" {
  description   = "Public address of Unifi controller"
  address_type  = "EXTERNAL"
  name          = "unifi-external-ip"
  network_tier  = "PREMIUM"
  prefix_length = "0"
  region        = "us-east1"
}

resource "google_compute_firewall" "allow_unifi" {
  allow {
    ports    = ["3478"]
    protocol = "udp"
  }

  allow {
    ports    = ["443", "6789", "80", "8080", "8443", "8843", "8880"]
    protocol = "tcp"
  }

  direction     = "INGRESS"
  disabled      = "false"
  name          = "allow-unifi"
  network       = "default"
  priority      = "1000"
  source_ranges = ["0.0.0.0/0"]
  target_tags   = ["unifi"]
}

resource "google_service_account" "unifi" {
  depends_on = [google_project_service.iam,]
  account_id   = "unifi-svc"
  display_name = "Unifi Service Account"
}

resource "google_compute_instance" "this" {
  provider     = google
  name         = "unifi-controller-instance"
  machine_type = "e2-micro"
  zone         = "us-east1-b"

  depends_on = [google_project_service.compute,]

  boot_disk {
    initialize_params {
      image = "debian-cloud/debian-9"
    }
  }

  network_interface {
    network = "default"
    access_config {
      nat_ip       = google_compute_address.external.address
      network_tier = google_compute_address.external.network_tier
    }
  }

 metadata = {
    startup-script-url = var.startup_script_url
    ddns-url = var.ddns_url
    timezone = var.timezone
    dns-name = var.dns_name
    bucket = google_storage_bucket.this.name
  }

  reservation_affinity {
    type = "ANY_RESERVATION"
  }

  scheduling {
    automatic_restart   = "true"
    min_node_cpus       = "0"
    on_host_maintenance = "MIGRATE"
    preemptible         = "false"
  }

  tags = google_compute_firewall.allow_unifi.target_tags

  service_account {
    email  = google_service_account.unifi.email
    scopes = ["https://www.googleapis.com/auth/devstorage.read_write", "https://www.googleapis.com/auth/logging.write", "https://www.googleapis.com/auth/monitoring.write", "https://www.googleapis.com/auth/service.management.readonly", "https://www.googleapis.com/auth/servicecontrol", "https://www.googleapis.com/auth/trace.append"]
  }

}

resource "google_project_service" "compute" {
  service = "compute.googleapis.com"
  timeouts {
    create = "30m"
    update = "40m"
  }
  disable_dependent_services = true
  disable_on_destroy = true
}

resource "google_project_service" "storage_api" {
  service = "storage-api.googleapis.com"
  timeouts {
    create = "30m"
    update = "40m"
  }
  disable_dependent_services = true
  disable_on_destroy = true
}

resource "google_project_service" "iam" {
  service = "iam.googleapis.com"
  timeouts {
    create = "30m"
    update = "40m"
  }
  disable_dependent_services = true
  disable_on_destroy = true
}

resource "google_storage_bucket" "this" {
  depends_on = [
    google_project_service.storage_api,
  ]
  name                        = var.bucket
  location                    = var.region
  force_destroy               = "false"
  storage_class               = "REGIONAL"
  uniform_bucket_level_access = "true"
}