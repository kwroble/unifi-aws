resource "google_compute_address" "tfer--unifi-external-ip" {
  address       = "35.229.125.188"
  address_type  = "EXTERNAL"
  name          = "unifi-external-ip"
  network_tier  = "PREMIUM"
  prefix_length = "0"
  region        = "us-east1"
}

resource "google_compute_disk" "tfer--us-east1-b-002F-unifi-controller" {
  image                     = "https://www.googleapis.com/compute/v1/projects/debian-cloud/global/images/debian-9-stretch-v20200714"
  name                      = "unifi-controller"
  physical_block_size_bytes = "4096"
  provisioned_iops          = "0"
  size                      = "15"
  type                      = "pd-standard"
  zone                      = "us-east1-b"
}

resource "google_compute_firewall" "tfer--allow-unifi" {
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
  network       = "${data.terraform_remote_state.local.outputs.google_compute_network_tfer--default_self_link}"
  priority      = "1000"
  source_ranges = ["0.0.0.0/0"]
  target_tags   = ["unifi"]
}

resource "google_compute_firewall" "tfer--default-allow-icmp" {
  allow {
    protocol = "icmp"
  }

  description   = "Allow ICMP from anywhere"
  direction     = "INGRESS"
  disabled      = "false"
  name          = "default-allow-icmp"
  network       = "${data.terraform_remote_state.local.outputs.google_compute_network_tfer--default_self_link}"
  priority      = "65534"
  source_ranges = ["0.0.0.0/0"]
}

resource "google_compute_firewall" "tfer--default-allow-internal" {
  allow {
    ports    = ["0-65535"]
    protocol = "tcp"
  }

  allow {
    ports    = ["0-65535"]
    protocol = "udp"
  }

  allow {
    protocol = "icmp"
  }

  description   = "Allow internal traffic on the default network"
  direction     = "INGRESS"
  disabled      = "false"
  name          = "default-allow-internal"
  network       = "${data.terraform_remote_state.local.outputs.google_compute_network_tfer--default_self_link}"
  priority      = "65534"
  source_ranges = ["10.128.0.0/9"]
}

resource "google_compute_firewall" "tfer--default-allow-rdp" {
  allow {
    ports    = ["3389"]
    protocol = "tcp"
  }

  description   = "Allow RDP from anywhere"
  direction     = "INGRESS"
  disabled      = "false"
  name          = "default-allow-rdp"
  network       = "${data.terraform_remote_state.local.outputs.google_compute_network_tfer--default_self_link}"
  priority      = "65534"
  source_ranges = ["0.0.0.0/0"]
}

resource "google_compute_firewall" "tfer--default-allow-ssh" {
  allow {
    ports    = ["22"]
    protocol = "tcp"
  }

  description   = "Allow SSH from anywhere"
  direction     = "INGRESS"
  disabled      = "false"
  name          = "default-allow-ssh"
  network       = "${data.terraform_remote_state.local.outputs.google_compute_network_tfer--default_self_link}"
  priority      = "65534"
  source_ranges = ["0.0.0.0/0"]
}

resource "google_compute_instance" "tfer--unifi-controller" {
  boot_disk {
    auto_delete = "true"
    device_name = "unifi-controller"
    mode        = "READ_WRITE"
    source      = "https://www.googleapis.com/compute/v1/projects/secure-potion-227516/zones/us-east1-b/disks/unifi-controller"
  }

  can_ip_forward      = "false"
  deletion_protection = "false"
  enable_display      = "false"
  machine_type        = "e2-micro"

  metadata = {
    bucket             = "maddie-daddy"
    ddns-url           = "http://freedns.afraid.org/dynamic/update.php?M3JlbzFMQVNzdVN5UUdmR0pkdHo6MTgwMDcwNzI="
    dns-name           = "king.thomastech.net"
    ssh-keys           = "kwroble_gmail_com:ssh-rsa AAAAB3NzaC1yc2EAAAABJQAAAQEAlDOpNQPDPxAVyLk2mJSgfHr/DYJ0njAx4NWVPbo4LSunC7LU7kRwJrR2pXYETfZ2NBwzV8bUI0A8tH4rakOMetePyXf9Dift7ZHcqeQBpshW/1HddHX2+QftyUP5envQC/u6Twgrsh9MgLXFwC4iPE7o8SsFXHxveFZiGY9hnAEwmudu+z9e5i+dZgLnKGCJBXkiW31/fXIEC4WMYsNDXjXcJXZjKFSPPhq1hQr6waj2HiR7PTPPsU7ji3NggnZoIQipcbz28eGcJvzL9+jpigoQryswNZmybuTvIhNVrPII621AKX40rvFLryYknITElW5UrN/cWBbVE3SlkmzbIw== kwroble_gmail_com"
    startup-script-url = "gs://petri-unifi/startup.sh"
    timezone           = "America/Detroit"
  }

  name = "unifi-controller"

  network_interface {
    access_config {
      nat_ip       = "35.229.125.188"
      network_tier = "PREMIUM"
    }

    network            = "https://www.googleapis.com/compute/v1/projects/secure-potion-227516/global/networks/default"
    network_ip         = "10.142.0.2"
    subnetwork         = "https://www.googleapis.com/compute/v1/projects/secure-potion-227516/regions/us-east1/subnetworks/default"
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

  service_account {
    email  = "204405319640-compute@developer.gserviceaccount.com"
    scopes = ["https://www.googleapis.com/auth/devstorage.read_write", "https://www.googleapis.com/auth/logging.write", "https://www.googleapis.com/auth/monitoring.write", "https://www.googleapis.com/auth/service.management.readonly", "https://www.googleapis.com/auth/servicecontrol", "https://www.googleapis.com/auth/trace.append"]
  }

  tags = ["unifi"]
  zone = "us-east1-b"
}

resource "google_compute_network" "tfer--default" {
  auto_create_subnetworks         = "true"
  delete_default_routes_on_create = "false"
  description                     = "Default network for the project"
  mtu                             = "0"
  name                            = "default"
  routing_mode                    = "REGIONAL"
}

resource "google_compute_route" "tfer--default-route-080534253aebe143" {
  description = "Default local route to the subnetwork 10.192.0.0/20."
  dest_range  = "10.192.0.0/20"
  name        = "default-route-080534253aebe143"
  network     = "${data.terraform_remote_state.local.outputs.google_compute_network_tfer--default_self_link}"
  priority    = "0"
  project     = "secure-potion-227516"
}

resource "google_compute_route" "tfer--default-route-08fb8bf1634da063" {
  description = "Default local route to the subnetwork 10.150.0.0/20."
  dest_range  = "10.150.0.0/20"
  name        = "default-route-08fb8bf1634da063"
  network     = "${data.terraform_remote_state.local.outputs.google_compute_network_tfer--default_self_link}"
  priority    = "0"
  project     = "secure-potion-227516"
}

resource "google_compute_route" "tfer--default-route-0cc149da52ee7418" {
  description = "Default local route to the subnetwork 10.174.0.0/20."
  dest_range  = "10.174.0.0/20"
  name        = "default-route-0cc149da52ee7418"
  network     = "${data.terraform_remote_state.local.outputs.google_compute_network_tfer--default_self_link}"
  priority    = "0"
  project     = "secure-potion-227516"
}

resource "google_compute_route" "tfer--default-route-1eac9ffcb29b635e" {
  description = "Default local route to the subnetwork 10.186.0.0/20."
  dest_range  = "10.186.0.0/20"
  name        = "default-route-1eac9ffcb29b635e"
  network     = "${data.terraform_remote_state.local.outputs.google_compute_network_tfer--default_self_link}"
  priority    = "0"
  project     = "secure-potion-227516"
}

resource "google_compute_route" "tfer--default-route-234b36392f387727" {
  description = "Default local route to the subnetwork 10.180.0.0/20."
  dest_range  = "10.180.0.0/20"
  name        = "default-route-234b36392f387727"
  network     = "${data.terraform_remote_state.local.outputs.google_compute_network_tfer--default_self_link}"
  priority    = "0"
  project     = "secure-potion-227516"
}

resource "google_compute_route" "tfer--default-route-35333fbebd4a6172" {
  description = "Default local route to the subnetwork 10.156.0.0/20."
  dest_range  = "10.156.0.0/20"
  name        = "default-route-35333fbebd4a6172"
  network     = "${data.terraform_remote_state.local.outputs.google_compute_network_tfer--default_self_link}"
  priority    = "0"
  project     = "secure-potion-227516"
}

resource "google_compute_route" "tfer--default-route-3671883629f04cf2" {
  description = "Default local route to the subnetwork 10.178.0.0/20."
  dest_range  = "10.178.0.0/20"
  name        = "default-route-3671883629f04cf2"
  network     = "${data.terraform_remote_state.local.outputs.google_compute_network_tfer--default_self_link}"
  priority    = "0"
  project     = "secure-potion-227516"
}

resource "google_compute_route" "tfer--default-route-49e0f7a5e0840229" {
  description = "Default local route to the subnetwork 10.194.0.0/20."
  dest_range  = "10.194.0.0/20"
  name        = "default-route-49e0f7a5e0840229"
  network     = "${data.terraform_remote_state.local.outputs.google_compute_network_tfer--default_self_link}"
  priority    = "0"
  project     = "secure-potion-227516"
}

resource "google_compute_route" "tfer--default-route-52dcb720163ed604" {
  description = "Default local route to the subnetwork 10.184.0.0/20."
  dest_range  = "10.184.0.0/20"
  name        = "default-route-52dcb720163ed604"
  network     = "${data.terraform_remote_state.local.outputs.google_compute_network_tfer--default_self_link}"
  priority    = "0"
  project     = "secure-potion-227516"
}

resource "google_compute_route" "tfer--default-route-5ec1855776e79ec5" {
  description = "Default local route to the subnetwork 10.148.0.0/20."
  dest_range  = "10.148.0.0/20"
  name        = "default-route-5ec1855776e79ec5"
  network     = "${data.terraform_remote_state.local.outputs.google_compute_network_tfer--default_self_link}"
  priority    = "0"
  project     = "secure-potion-227516"
}

resource "google_compute_route" "tfer--default-route-6966320a7664f95e" {
  description = "Default local route to the subnetwork 10.196.0.0/20."
  dest_range  = "10.196.0.0/20"
  name        = "default-route-6966320a7664f95e"
  network     = "${data.terraform_remote_state.local.outputs.google_compute_network_tfer--default_self_link}"
  priority    = "0"
  project     = "secure-potion-227516"
}

resource "google_compute_route" "tfer--default-route-6f67f0fca0b9bca7" {
  description = "Default local route to the subnetwork 10.146.0.0/20."
  dest_range  = "10.146.0.0/20"
  name        = "default-route-6f67f0fca0b9bca7"
  network     = "${data.terraform_remote_state.local.outputs.google_compute_network_tfer--default_self_link}"
  priority    = "0"
  project     = "secure-potion-227516"
}

resource "google_compute_route" "tfer--default-route-706cae88d9eb0524" {
  description = "Default local route to the subnetwork 10.140.0.0/20."
  dest_range  = "10.140.0.0/20"
  name        = "default-route-706cae88d9eb0524"
  network     = "${data.terraform_remote_state.local.outputs.google_compute_network_tfer--default_self_link}"
  priority    = "0"
  project     = "secure-potion-227516"
}

resource "google_compute_route" "tfer--default-route-75f7f500f7c1e845" {
  description = "Default local route to the subnetwork 10.172.0.0/20."
  dest_range  = "10.172.0.0/20"
  name        = "default-route-75f7f500f7c1e845"
  network     = "${data.terraform_remote_state.local.outputs.google_compute_network_tfer--default_self_link}"
  priority    = "0"
  project     = "secure-potion-227516"
}

resource "google_compute_route" "tfer--default-route-7a3f0d3b45b1713f" {
  description = "Default local route to the subnetwork 10.162.0.0/20."
  dest_range  = "10.162.0.0/20"
  name        = "default-route-7a3f0d3b45b1713f"
  network     = "${data.terraform_remote_state.local.outputs.google_compute_network_tfer--default_self_link}"
  priority    = "0"
  project     = "secure-potion-227516"
}

resource "google_compute_route" "tfer--default-route-8307b8df14f3616a" {
  description = "Default local route to the subnetwork 10.132.0.0/20."
  dest_range  = "10.132.0.0/20"
  name        = "default-route-8307b8df14f3616a"
  network     = "${data.terraform_remote_state.local.outputs.google_compute_network_tfer--default_self_link}"
  priority    = "0"
  project     = "secure-potion-227516"
}

resource "google_compute_route" "tfer--default-route-8cad943dc88ebb54" {
  description = "Default local route to the subnetwork 10.158.0.0/20."
  dest_range  = "10.158.0.0/20"
  name        = "default-route-8cad943dc88ebb54"
  network     = "${data.terraform_remote_state.local.outputs.google_compute_network_tfer--default_self_link}"
  priority    = "0"
  project     = "secure-potion-227516"
}

resource "google_compute_route" "tfer--default-route-8dcf62e95dc4e482" {
  description = "Default local route to the subnetwork 10.166.0.0/20."
  dest_range  = "10.166.0.0/20"
  name        = "default-route-8dcf62e95dc4e482"
  network     = "${data.terraform_remote_state.local.outputs.google_compute_network_tfer--default_self_link}"
  priority    = "0"
  project     = "secure-potion-227516"
}

resource "google_compute_route" "tfer--default-route-917185dde4ed9c74" {
  description = "Default local route to the subnetwork 10.154.0.0/20."
  dest_range  = "10.154.0.0/20"
  name        = "default-route-917185dde4ed9c74"
  network     = "${data.terraform_remote_state.local.outputs.google_compute_network_tfer--default_self_link}"
  priority    = "0"
  project     = "secure-potion-227516"
}

resource "google_compute_route" "tfer--default-route-9d1f55e21b960275" {
  description = "Default local route to the subnetwork 10.188.0.0/20."
  dest_range  = "10.188.0.0/20"
  name        = "default-route-9d1f55e21b960275"
  network     = "${data.terraform_remote_state.local.outputs.google_compute_network_tfer--default_self_link}"
  priority    = "0"
  project     = "secure-potion-227516"
}

resource "google_compute_route" "tfer--default-route-ae0a5c442d872c9d" {
  description = "Default local route to the subnetwork 10.168.0.0/20."
  dest_range  = "10.168.0.0/20"
  name        = "default-route-ae0a5c442d872c9d"
  network     = "${data.terraform_remote_state.local.outputs.google_compute_network_tfer--default_self_link}"
  priority    = "0"
  project     = "secure-potion-227516"
}

resource "google_compute_route" "tfer--default-route-bbd10e67ce3f1df3" {
  description = "Default local route to the subnetwork 10.138.0.0/20."
  dest_range  = "10.138.0.0/20"
  name        = "default-route-bbd10e67ce3f1df3"
  network     = "${data.terraform_remote_state.local.outputs.google_compute_network_tfer--default_self_link}"
  priority    = "0"
  project     = "secure-potion-227516"
}

resource "google_compute_route" "tfer--default-route-bcc5b4396e5e8bfc" {
  description = "Default local route to the subnetwork 10.190.0.0/20."
  dest_range  = "10.190.0.0/20"
  name        = "default-route-bcc5b4396e5e8bfc"
  network     = "${data.terraform_remote_state.local.outputs.google_compute_network_tfer--default_self_link}"
  priority    = "0"
  project     = "secure-potion-227516"
}

resource "google_compute_route" "tfer--default-route-c3e35b160e316654" {
  description = "Default local route to the subnetwork 10.128.0.0/20."
  dest_range  = "10.128.0.0/20"
  name        = "default-route-c3e35b160e316654"
  network     = "${data.terraform_remote_state.local.outputs.google_compute_network_tfer--default_self_link}"
  priority    = "0"
  project     = "secure-potion-227516"
}

resource "google_compute_route" "tfer--default-route-c56721e13ba605fb" {
  description = "Default local route to the subnetwork 10.152.0.0/20."
  dest_range  = "10.152.0.0/20"
  name        = "default-route-c56721e13ba605fb"
  network     = "${data.terraform_remote_state.local.outputs.google_compute_network_tfer--default_self_link}"
  priority    = "0"
  project     = "secure-potion-227516"
}

resource "google_compute_route" "tfer--default-route-c8f44ebf1b6e0ff5" {
  description = "Default local route to the subnetwork 10.164.0.0/20."
  dest_range  = "10.164.0.0/20"
  name        = "default-route-c8f44ebf1b6e0ff5"
  network     = "${data.terraform_remote_state.local.outputs.google_compute_network_tfer--default_self_link}"
  priority    = "0"
  project     = "secure-potion-227516"
}

resource "google_compute_route" "tfer--default-route-cd04f51017fdfaad" {
  description = "Default local route to the subnetwork 10.170.0.0/20."
  dest_range  = "10.170.0.0/20"
  name        = "default-route-cd04f51017fdfaad"
  network     = "${data.terraform_remote_state.local.outputs.google_compute_network_tfer--default_self_link}"
  priority    = "0"
  project     = "secure-potion-227516"
}

resource "google_compute_route" "tfer--default-route-d243bf68c9f8d136" {
  description = "Default local route to the subnetwork 10.160.0.0/20."
  dest_range  = "10.160.0.0/20"
  name        = "default-route-d243bf68c9f8d136"
  network     = "${data.terraform_remote_state.local.outputs.google_compute_network_tfer--default_self_link}"
  priority    = "0"
  project     = "secure-potion-227516"
}

resource "google_compute_route" "tfer--default-route-e723af00749ddd26" {
  description = "Default local route to the subnetwork 10.182.0.0/20."
  dest_range  = "10.182.0.0/20"
  name        = "default-route-e723af00749ddd26"
  network     = "${data.terraform_remote_state.local.outputs.google_compute_network_tfer--default_self_link}"
  priority    = "0"
  project     = "secure-potion-227516"
}

resource "google_compute_route" "tfer--default-route-f86482ad43250db2" {
  description = "Default local route to the subnetwork 10.142.0.0/20."
  dest_range  = "10.142.0.0/20"
  name        = "default-route-f86482ad43250db2"
  network     = "${data.terraform_remote_state.local.outputs.google_compute_network_tfer--default_self_link}"
  priority    = "0"
  project     = "secure-potion-227516"
}

resource "google_compute_route" "tfer--default-route-fd9533959c2ccc94" {
  description      = "Default route to the Internet."
  dest_range       = "0.0.0.0/0"
  name             = "default-route-fd9533959c2ccc94"
  network          = "${data.terraform_remote_state.local.outputs.google_compute_network_tfer--default_self_link}"
  next_hop_gateway = "https://www.googleapis.com/compute/v1/projects/secure-potion-227516/global/gateways/default-internet-gateway"
  priority         = "1000"
  project          = "secure-potion-227516"
}

resource "google_compute_subnetwork" "tfer--default" {
  ip_cidr_range              = "10.142.0.0/20"
  name                       = "default"
  network                    = "${data.terraform_remote_state.local.outputs.google_compute_network_tfer--default_self_link}"
  private_ip_google_access   = "false"
  private_ipv6_google_access = "DISABLE_GOOGLE_ACCESS"
  project                    = "secure-potion-227516"
  purpose                    = "PRIVATE"
  region                     = "us-east1"
  stack_type                 = "UNSPECIFIED_STACK_TYPE"
}

resource "google_project" "tfer--secure-potion-227516" {
  auto_create_network = "true"
  billing_account     = "01C382-EBF73F-1E791F"
  name                = "Kyle's Project"
  project_id          = "secure-potion-227516"
}

resource "google_storage_bucket" "tfer--maddie-daddy" {
  default_event_based_hold    = "false"
  force_destroy               = "false"
  location                    = "US-EAST1"
  name                        = "maddie-daddy"
  project                     = "secure-potion-227516"
  requester_pays              = "false"
  storage_class               = "REGIONAL"
  uniform_bucket_level_access = "false"
}

resource "google_storage_bucket_acl" "tfer--maddie-daddy" {
  bucket = "maddie-daddy"
}

resource "google_storage_bucket_iam_binding" "tfer--maddie-daddy" {
  bucket = "b/maddie-daddy"
}

resource "google_storage_bucket_iam_policy" "tfer--maddie-daddy" {
  bucket = "b/maddie-daddy"

  policy_data = <<POLICY
{
  "bindings": [
    {
      "members": [
        "projectEditor:secure-potion-227516",
        "projectOwner:secure-potion-227516"
      ],
      "role": "roles/storage.legacyBucketOwner"
    },
    {
      "members": [
        "projectViewer:secure-potion-227516"
      ],
      "role": "roles/storage.legacyBucketReader"
    }
  ]
}
POLICY
}

resource "google_storage_default_object_acl" "tfer--maddie-daddy" {
  bucket      = "maddie-daddy"
  role_entity = ["OWNER:project-editors-204405319640", "OWNER:project-owners-204405319640", "READER:project-viewers-204405319640"]
}
