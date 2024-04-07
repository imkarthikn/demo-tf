terraform {
  backend "s3" {
    bucket         = "tf-demo-s3-backend"
    key            = "terraform.tfstate"
    region         = "us-east-1" 
#    dynamodb_table = "terraform_locks"
    encrypt        = true
  }
}

provider "aws" {
  region = "us-east-1" 
}
