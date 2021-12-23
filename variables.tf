variable "region" {
  default = "us-east-1"
}

variable "bucket" {
  description = "Name of s3 bucket used to store Unifi backups"
  default = "unifi-controller-kyle-bucket"
}

variable "startup_script_url" {
  description = "Path to Unifi controller creation script"
  default = "gs://petri-unifi/startup.sh"
}

variable "ddns_url" {
  default = "http://freedns.afraid.org/dynamic/update.php?M3JlbzFMQVNzdVN5UUdmR0pkdHo6MTgwMDcwNzI="
}

variable "timezone" {
  default = "America/Detroit"
}

variable "dns_name" {
  default = "king.thomastech.net"
}