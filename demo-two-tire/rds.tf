# Create RDS instance
resource "aws_db_instance" "main" {
  allocated_storage    = var.db_allocated_storage
  storage_type         = "gp2"
  engine               = var.db_engine
  engine_version       = var.db_engine_version
  instance_class       = var.db_instance_class
  db_name              = var.db_instance_name
  username             = var.db_username
  password             = var.db_password
  multi_az             = var.db_multi_az
  db_subnet_group_name = aws_db_subnet_group.rds_subnet_group.name
  tags = var.common_tags
   skip_final_snapshot      = true
  final_snapshot_identifier = "my-final-snapshot"
}
