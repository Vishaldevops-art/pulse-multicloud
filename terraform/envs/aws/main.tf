# AWS environment root. Init with:  terraform init -backend-config=backend.hcl
# (backend.hcl comes from the bootstrap/aws output and is git-ignored)

terraform {
  required_version = ">= 1.10"
  required_providers {
    aws = { source = "hashicorp/aws", version = "~> 6.0" }
  }
  backend "s3" {}
}

variable "region" {
  type    = string
  default = "ap-south-1"
}

provider "aws" {
  region = var.region
  default_tags {
    tags = { project = "pulse-multicloud", env = "lab" }
  }
}

# Week 5 - uncomment as you build the modules.
# module "network" {
#   source     = "../../modules/aws-network"
#   name       = "pulse"
#   cidr_block = "10.20.0.0/16"
# }
#
# module "eks" {
#   source     = "../../modules/aws-eks"
#   name       = "pulse"
#   vpc_id     = module.network.vpc_id
#   subnet_ids = module.network.public_subnet_ids
# }
