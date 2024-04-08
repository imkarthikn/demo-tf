# Create VPC
resource "aws_vpc" "main" {
  cidr_block = var.vpc_cidr_block
  enable_dns_support = true
  enable_dns_hostnames = true
  #name = demo
  tags = var.common_tags
}

data "aws_availability_zones" "available" {
  state = "available"
}

# Create public subnets
resource "aws_subnet" "public" {
  count             = length(var.public_subnet_cidr_blocks)
  vpc_id            = aws_vpc.main.id
  cidr_block        = var.public_subnet_cidr_blocks[count.index]
  availability_zone = element(data.aws_availability_zones.available.names, count.index)
  depends_on        = [aws_vpc.main]
  tags = var.common_tags
}

# Create private subnets
resource "aws_subnet" "private" {
  count             = length(var.private_subnet_cidr_blocks)
  vpc_id            = aws_vpc.main.id
  cidr_block        = var.private_subnet_cidr_blocks[count.index]
  availability_zone = element(data.aws_availability_zones.available.names, count.index)
  depends_on        = [aws_vpc.main]
  tags = var.common_tags
}

# Create internet gateway
resource "aws_internet_gateway" "gw" {
  vpc_id = aws_vpc.main.id
  depends_on        = [aws_vpc.main]
  tags = var.common_tags
}

# Create NAT gateways
resource "aws_nat_gateway" "nat" {
  count           = var.nat_gateway_count
  allocation_id   = aws_eip.nat[count.index].id
  subnet_id       = aws_subnet.public[count.index].id
  tags = var.common_tags
}

# Create EIPs for NAT gateways
resource "aws_eip" "nat" {
  count = var.nat_gateway_count
  vpc   = true
  tags = var.common_tags
}

# Create routing table for public subnets
resource "aws_route_table" "public" {
  vpc_id = aws_vpc.main.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.gw.id
  }
  depends_on = [aws_vpc.main]
}

# Associate routing table with public subnets
resource "aws_route_table_association" "public" {
  count          = length(aws_subnet.public)
  subnet_id      = aws_subnet.public[count.index].id
  route_table_id = aws_route_table.public.id
}

# Create routing table for private subnets
resource "aws_route_table" "private" {
  count  = length(aws_subnet.private)
  vpc_id = aws_vpc.main.id
  depends_on = [aws_vpc.main]
}

# Associate routing table with private subnets
resource "aws_route_table_association" "private" {
  count          = length(aws_subnet.private)
  subnet_id      = aws_subnet.private[count.index].id
  route_table_id = aws_route_table.private[count.index].id
}

# Add default route to NAT gateway for private subnets
resource "aws_route" "private_nat" {
  count                  = length(aws_subnet.private)
  route_table_id         = aws_route_table.private[count.index].id
  destination_cidr_block = "0.0.0.0/0"
  nat_gateway_id         = aws_nat_gateway.nat[count.index].id
}

# Create security groups
resource "aws_security_group" "load_balancer" {
  vpc_id = aws_vpc.main.id
  depends_on = [aws_vpc.main]
  tags = var.common_tags

  // Define security group rules for load balancer
  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_security_group" "application" {
  vpc_id = aws_vpc.main.id
  depends_on = [aws_vpc.main]
  tags = var.common_tags

  // Define security group rules for application instances
  // For example, allow HTTP traffic from load balancer
  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    security_groups = [aws_security_group.load_balancer.id]
  }
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]  # Allow all outbound traffic
  }
}

resource "aws_security_group" "rds" {
  vpc_id = aws_vpc.main.id
  depends_on = [aws_vpc.main]
  tags = var.common_tags

  // Define security group rules for RDS
  // For example, allow MySQL traffic from application instances
  ingress {
    from_port   = 3306
    to_port     = 3306
    protocol    = "tcp"
    security_groups = [aws_security_group.application.id]
  }
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]  # Allow all outbound traffic
  }
}

resource "aws_security_group" "alb_sg" {
  name        = "alb-sg"
  description = "Security group for Application Load Balancer"
  vpc_id      = aws_vpc.main.id

  // Define security group rules for the ALB
  // Allow inbound traffic on port 80 from anywhere
  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  // Allow outbound traffic to the private subnet
 egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]  # Allow all outbound traffic
  }

  tags = var.common_tags
}


# Create RDS subnet group
resource "aws_db_subnet_group" "rds_subnet_group" {
  name       = "rds-subnet-group"
  subnet_ids = [aws_subnet.private[0].id, aws_subnet.private[1].id]
  depends_on = [aws_subnet.private]
}

# Create IAM role for application instances
resource "aws_iam_role" "application_role" {
  name = "application-role"

  assume_role_policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Principal": {
        "Service": "ec2.amazonaws.com"
      },
      "Action": "sts:AssumeRole"
    }
  ]
}
EOF
}

# Attach permissions policy for CloudWatch Logs and custom metrics
resource "aws_iam_policy_attachment" "cloudwatch_policy_attachment" {
  name       = "cloudwatch-policy-attachment"
  roles      = [aws_iam_role.application_role.name]
  policy_arn = "arn:aws:iam::aws:policy/CloudWatchFullAccess"
}


