# Define the required providers
terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 3.34.0"
    }
  }
}

variable "aws_region" {
  type        = string
  description = "The AWS region to put the bucket into"
  default     = "us-east-1"
}

variable "bucket_name" {
  type        = string
  description = "The name of our bucket"
  default     = "my-bucket"
}

variable "sync_directory" {
  type        = string
  description = "directory that will be synced"
  default     = "bucket"
}

# Configure the AWS Provider
provider "aws" {
  region  = var.aws_region
  profile = "default"
}

# Creates bucket to store the static website
resource "aws_s3_bucket" "bucket" {
  bucket = var.bucket_name
  acl    = "private"
}

# Creates s3 objects sourced from var.sync_directory that are tracked with an etag for changes.
resource "aws_s3_bucket_object" "object" {
  for_each = fileset("${path.module}/${var.sync_directory}", "**")
  bucket  = aws_s3_bucket.bucket.id
  key     = each.value
  source  = "${path.module}/${var.sync_directory}/${each.value}"
  etag    = filemd5("${path.module}/${var.sync_directory}/${each.value}")
}
