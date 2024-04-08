resource "aws_lb" "app_lb" {
  name               = var.alb_name
  internal           = false
  load_balancer_type = "application"
  security_groups    = [aws_security_group.alb_sg.id]
  subnets            = aws_subnet.public[*].id

  tags = {
    Name = var.alb_name
  }
}

resource "aws_lb_target_group" "app_target_group" {
  name        = "app-target-group"
  port        = 80
  protocol    = "HTTP"
  vpc_id      = aws_vpc.main.id
  target_type = "instance"

  health_check {
    path                = "/"
    port                = 80
    protocol            = "HTTP"
    timeout             = 5
    interval            = 30
    healthy_threshold   = 2
    unhealthy_threshold = 2
    matcher             = "200"
  }
}

# Create ALB listener
resource "aws_lb_listener" "web" {
  load_balancer_arn = aws_lb.app_lb.arn
  port              = 80
  protocol          = "HTTP"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.app_target_group.arn
  }
}

# Output ALB DNS name
output "alb_dns_name" {
  value = aws_lb.app_lb.dns_name
}
