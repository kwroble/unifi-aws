terraform {
    backend "s3" {
        bucket="wroble-79347"
        region="us-east-1"
        dynamodb_table="wroble-tfstatelock-79347"
        key = "networking/unifi-vpc/terraform.tfstate"
    }
}