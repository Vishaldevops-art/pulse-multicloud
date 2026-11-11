# Creates the S3 bucket that holds Terraform remote state.
# Locking uses S3 native lockfiles (use_lockfile = true, Terraform >= 1.10) - no DynamoDB table needed.
# Interview note: older setups use a DynamoDB table (hash key "LockID") for locking; that option is now deprecated.
# Run ONCE with local state:  terraform init; terraform plan; terraform apply
# Needs: aws configure sso (or another profile) - check with `aws sts get-caller-identity`.

terraform {
  required_version = ">= 1.10"
  required_providers {
    aws    = { source = "hashicorp/aws", version = "~> 6.0" }
    random = { source = "hashicorp/random", version = "~> 3.6" }
  }
}

variable "region" {
  type    = string
  default = "ap-south-1"
}

provider "aws" {
  region = var.region
  default_tags {
    tags = { project = "pulse-multicloud", purpose = "terraform-state" }
  }
}

resource "random_string" "suffix" {
  length  = 6
  upper   = false
  special = false
}

resource "aws_s3_bucket" "tfstate" {
  bucket = "pulse-tfstate-${random_string.suffix.result}"
  # force_destroy = true   # uncomment only when tearing everything down at the end
}

resource "aws_s3_bucket_versioning" "tfstate" {
  bucket = aws_s3_bucket.tfstate.id
  versioning_configuration {
    status = "Enabled"
  }
}

resource "aws_s3_bucket_server_side_encryption_configuration" "tfstate" {
  bucket = aws_s3_bucket.tfstate.id
  rule {
    apply_server_side_encryption_by_default {
      sse_algorithm = "AES256"
    }
  }
}

resource "aws_s3_bucket_public_access_block" "tfstate" {
  bucket                  = aws_s3_bucket.tfstate.id
  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

output "backend_config" {
  description = "Paste into envs/aws/backend.hcl"
  value       = <<-EOT
    bucket       = "${aws_s3_bucket.tfstate.bucket}"
    key          = "aws/pulse.tfstate"
    region       = "${var.region}"
    use_lockfile = true
    encrypt      = true
  EOT
}
