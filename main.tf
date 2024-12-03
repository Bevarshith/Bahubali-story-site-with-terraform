# Declare aws_region variable
variable "aws_region" {
  description = "The AWS region where the resources will be created"
  type        = string
  default     = "us-east-1"  # You can change this to any AWS region you prefer
}

# Provider Configuration - AWS Provider
provider "aws" {
  region = var.aws_region  # Use the variable to allow dynamic region selection
}

# Generate a random suffix for a globally unique S3 bucket name
resource "random_id" "unique_suffix" {
  byte_length = 4  # Generates a 32-bit random string (base64 encoded)
}

# Create the S3 Bucket to store static website files
resource "aws_s3_bucket" "website_bucket" {
  bucket = "static-website-bahubali-rajulakey-raju"  # Ensure this name is globally unique
}

# Allow public access to the S3 bucket
resource "aws_s3_bucket_public_access_block" "block_public" {
  bucket = aws_s3_bucket.website_bucket.id

  block_public_acls       = false
  block_public_policy     = false
  ignore_public_acls      = false
  restrict_public_buckets = false
}

# Configure the S3 bucket for static website hosting using the aws_s3_bucket_website_configuration resource
resource "aws_s3_bucket_website_configuration" "website_config" {
  bucket = aws_s3_bucket.website_bucket.id

  index_document {
    suffix = "index.html"
  }

  error_document {
    key = "error.html"
  }
}

# Upload index.html to the S3 bucket
resource "aws_s3_object" "index" {
  bucket      = aws_s3_bucket.website_bucket.bucket
  key         = "index.html"
  source      = "index.html"  # Ensure this file is in the same directory as your main.tf
  content_type = "text/html"
}

# Upload error.html to the S3 bucket
resource "aws_s3_object" "error" {
  bucket      = aws_s3_bucket.website_bucket.bucket
  key         = "error.html"
  source      = "error.html"  # Ensure this file is in the same directory as your main.tf
  content_type = "text/html"
}

# Define the S3 bucket policy to allow public read access to files
resource "aws_s3_bucket_policy" "public_read_access" {
  bucket = aws_s3_bucket.website_bucket.id
  policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Principal": "*",
      "Action": ["s3:GetObject"],
      "Resource": [
        "${aws_s3_bucket.website_bucket.arn}/*"
      ]
    }
  ]
}
EOF
}

# Output the website URL
output "website_url" {
  value = "http://${aws_s3_bucket.website_bucket.bucket}.s3-website-${var.aws_region}.amazonaws.com"
}
