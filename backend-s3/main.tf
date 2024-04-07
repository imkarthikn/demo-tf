provider "aws" {
  region = var.region
}

resource "aws_s3_bucket" "terraform_state_bucket" {
  bucket = var.bucket_name
  acl    = "private"
}
