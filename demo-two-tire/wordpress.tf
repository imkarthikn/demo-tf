# Create launch configuration
resource "aws_launch_configuration" "app_launch_config" {
  name                 = "app-launch-config"
  image_id             = data.aws_ami.latest.id
  instance_type         = var.instance_type
  iam_instance_profile = aws_iam_instance_profile.application_instance_profile.name
  depends_on = [aws_lb.app_lb]

  # User data script with fixed CloudWatch agent configuration
  user_data = <<-EOF
    #!/bin/bash
    yum update -y

    # Install and configure web server (replace with your actual choices)
    yum install -y nginx php-fpm php-mysql

    # Start web server and PHP-FPM services
    systemctl start nginx
    systemctl enable nginx
    systemctl start php-fpm
    systemctl enable php-fpm
    # Install WordPress
    cd /var/www/html
    wget https://wordpress.org/latest.tar.gz
    tar -xzf latest.tar.gz
    mv wordpress/* .
    rm -rf wordpress latest.tar.gz

    # Configure WordPress to use RDS as database
    cat > wp-config.php <<EOL
    <?php
    define('DB_NAME', '${var.db_instance_name}');
    define('DB_USER', '${var.db_username}');
    define('DB_PASSWORD', '${var.db_password}');
    define('DB_HOST', '${aws_db_instance.main.endpoint}');
    define('DB_CHARSET', 'utf8mb4');
    define('DB_COLLATE', '');

    # Other WordPress configuration settings...

    EOL

    chown -R nginx:nginx /var/www/html

    # Restart nginx and PHP-FPM to apply changes
    systemctl restart nginx
    systemctl restart php-fpm
    

    # Install CloudWatch agent
    yum install -y amazon-cloudwatch-agent
    systemctl start amazon-cloudwatch-agent
    systemctl enable amazon-cloudwatch-agent

    # Configure CloudWatch agent to export logs (use instance ID for log stream name)
    cat <<EOF2 >> /etc/cloudwatch-agent-config.json
    {
      "logs": {
        "logs_collected": {
          "files": {
            "collect_list": [
              {
                "file_path": "/var/log/messages",
                "log_group_name": "var_log_messages",
                "log_stream_name": "{instance_id}",  # Use instance ID
                "timezone": "UTC"
              }
            ]
          }
        }
      },
      "metrics": {
        "append_dimensions": {
          "InstanceId": "{instance_id}"  # Use instance ID for dimension
        },
        "metrics_collected": {
          "mem": {
            "measurement": [
              "mem_used_percent"
            ],
            "metrics_collection_interval": 60,
            "resources": [
              "*"
            ]
          },
          "disk": {
            "measurement": [
              "used_percent"
            ],
            "metrics_collection_interval": 60,
            "resources": [
              "/"
            ]
          }
        }
      }
    }
    EOF2
    systemctl restart amazon-cloudwatch-agent
  EOF

  security_groups = [aws_security_group.application.id]
  key_name = var.key_name

  lifecycle {
    create_before_destroy = true
  }
  # placement_tenancy    = "default"  # Optional, use if needed
  associate_public_ip_address = false
}

# Data source to get the latest Amazon Linux AMI
data "aws_ami" "latest" {
  most_recent = true
  filter {
    name   = "name"
    values = [var.ami_filter]
  }
}

# Create IAM instance profile
resource "aws_iam_instance_profile" "application_instance_profile" {
  name = "application-instance-profile"
  role = aws_iam_role.application_role.name
}

# Create auto scaling group
resource "aws_autoscaling_group" "app_asg" {
  desired_capacity  = 2
  min_size          = 2
  max_size          = 2
  launch_configuration = aws_launch_configuration.app_launch_config.name
  vpc_zone_identifier = aws_subnet.private[*].id
  #vpc_zone_identifier  = concat(aws_subnet.public[*].id, aws_subnet.private[*].id)
  target_group_arns = [aws_lb_target_group.app_target_group.arn]
  #iam_instance_profile = aws_iam_instance_profile.application_instance_profile.name
  depends_on = [aws_lb.app_lb]

  tag {
    key               = "Name"
    value             = "app-instance"
    propagate_at_launch = true
  }
}

# Create SNS topic for alarm notifications (unchanged)
resource "aws_sns_topic" "alarm_notifications" {
  name = "alarm-notifications"
}
