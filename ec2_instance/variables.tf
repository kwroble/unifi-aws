##################################################################################
# VARIABLES
##################################################################################

variable "region" {
  type    = string
  default = "us-east-1"
}

variable "network_state_bucket" {
  type        = string
  description = "name of bucket used for network state"
}

variable "network_state_key" {
  type        = string
  description = "name of key used for network state"
  default     = "networking/unifi-vpc/terraform.tfstate"
}

variable "network_state_region" {
  type        = string
  description = "region used for network state"
  default     = "us-east-1"
}

variable "ddns_url" {
  default = "https://freedns.afraid.org/dynamic/update.php?M3JlbzFMQVNzdVN5UUdmR0pkdHo6MTgwMDcwNzE="
}

variable "timezone" {
  default = "America/Detroit"
}

variable "dns_name" {
  default = "madelyn.mooo.com"
}

variable "bucket" {
  description = "Name of s3 bucket used to store Unifi backups"
  default = "unifi-controller-kyle-bucket"
}

variable "unifi_ports_tcp" {
  description = "TCP ingress ports"
  default = ["443", "6789", "80", "8080", "8443", "8843", "8880"]
}

variable "unifi_ports_udp" {
  description = "UDP ingress ports"
  default = ["3478"]
}