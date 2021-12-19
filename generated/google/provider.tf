provider "google" {
  project = "secure-potion-227516"
}

terraform {
	required_providers {
		google = {
	    version = "~> 4.0.0"
		}
  }
}
