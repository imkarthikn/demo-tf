variable "bucket_name" {
  description = "Name for the Terraform state bucket"
  type        = string
  default     = "tf-demo-s3-backend"
}

variable "region" {
  description = "AWS region for the S3 bucket"
  type        = string
  default     = "us-east-1"
}
