variable "region" {
  description = "AWS region"
  type        = string
  default     = "us-east-1"
}

variable "vpc_cidr_block" {
  description = "CIDR block for the VPC"
  type        = string
  default     = "10.4.0.0/16"
}

variable "public_subnet_cidr_blocks" {
  description = "CIDR blocks for public subnets"
  type        = list(string)
  default     = ["10.4.1.0/24", "10.4.2.0/24"]
}

variable "private_subnet_cidr_blocks" {
  description = "CIDR blocks for private subnets"
  type        = list(string)
  default     = ["10.4.3.0/24", "10.4.4.0/24"]
}

variable "nat_gateway_count" {
  description = "Number of NAT gateways (should match the number of public subnets)"
  type        = number
  default     = 2
}

variable "enable_flow_logs" {
  description = "Enable VPC flow logs"
  type        = bool
  default     = true
}

variable "db_instance_name" {
  description = "Name for the RDS instance"
  type        = string
  default     = "mydb"
}

variable "db_username" {
  description = "Username for the RDS instance"
  type        = string
  default     = "admin"
}

variable "db_password" {
  description = "Password for the RDS instance"
  type        = string
  default     = "mypassword"
}

variable "db_instance_class" {
  description = "RDS instance class"
  type        = string
  default     = "db.t3.micro"
}

variable "db_engine" {
  description = "Database engine for RDS"
  type        = string
  default     = "mysql"
}

variable "db_engine_version" {
  description = "Database engine version for RDS"
  type        = string
  default     = "5.7"
}

variable "db_allocated_storage" {
  description = "Allocated storage for RDS (in GB)"
  type        = number
  default     = 20
}

variable "db_multi_az" {
  description = "Enable multi-AZ deployment for RDS"
  type        = bool
  default     = true
}

variable "common_tags" {
  type = map(string)
  default = {
    Environment = "Demo"
    Project     = "terraform-demo"
  }
}

variable "ami_filter" {
  description = "Filter for selecting the newest Amazon Linux AMI"
  type        = string
  default     = "amzn2-ami-hvm-*-x86_64-ebs"
}

variable "instance_type" {
  description = "Instance type for application instances"
  type        = string
  default     = "t2.micro"
}

variable "key_name" {
  description = "The name of the SSH key pair to use for the EC2 instances"
  type        = string
  default     = "demo"
}

# variables.tf

variable "alb_name" {
  description = "Name of the Application Load Balancer"
  type        = string
  default     = "demo"
}




