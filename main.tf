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

variable "website_domain_main" {
  type        = string
  description = "The main website domain name that will be receiving the traffic"
  default     = "bigsby.io"
}

variable "tags" {
  description = "Tags added to resources"
  default     = {}
  type        = map(string)
}

variable "site_output_dir" {
  type        = string
  description = "directory in src that contains the static site generated"
  default     = "out"
}

# Configure the AWS Provider
provider "aws" {
  region  = var.aws_region
  profile = "default"
}


# Creates bucket to store the static website
resource "aws_s3_bucket" "website_root" {
  bucket = "${var.website_domain_main}-root"
  acl    = "private"
  tags = {
    Name        = "My bucket"
    Environment = "Dev"
  }
}

# Creates s3 objects sourced from var.site_output_dir that are tracked with an etag for changes.
resource "aws_s3_bucket_object" "object" {
  for_each = fileset("${path.module}/../${var.site_output_dir}", "**")
  bucket  = aws_s3_bucket.website_root.id
  key     = each.value
  source  = "${path.module}/../${var.site_output_dir}/${each.value}"
  etag    = filemd5("${path.module}/../${var.site_output_dir}/${each.value}")
}
