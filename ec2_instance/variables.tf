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
  default = "http://freedns.afraid.org/dynamic/update.php?M3JlbzFMQVNzdVN5UUdmR0pkdHo6MTgwMDcwNzI="
}

variable "timezone" {
  default = "America/Detroit"
}

variable "dns_name" {
  default = "king.thomastech.net"
}