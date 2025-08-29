############################################################
# Security Groups
# - frontend_alb_sg: public entry; allow HTTP from internet
# - frontend_ec2_sg: allow HTTP only from frontend ALB SG
############################################################
resource "aws_security_group" "frontend_alb_sg" {
  name        = "${var.project_name}-frontend-alb-sg"
  description = "Ingress to public frontend ALB"
  vpc_id      = var.vpc_id

  # Public HTTP ingress (add HTTPS later if you terminate TLS on the ALB)
  ingress {
    description = "HTTP from anywhere"
    from_port   = var.frontend_listen_port
    to_port     = var.frontend_listen_port
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = { Name = "${var.project_name}-frontend-alb-sg", Tier = "web" }
}

resource "aws_security_group" "frontend_ec2_sg" {
  name        = "${var.project_name}-frontend-ec2-sg"
  description = "Frontend instances"
  vpc_id      = var.vpc_id

  # Ingress ONLY from the frontend ALB SG on the frontend port
  ingress {
    description     = "HTTP from frontend ALB"
    from_port       = var.frontend_listen_port
    to_port         = var.frontend_listen_port
    protocol        = "tcp"
    security_groups = [aws_security_group.frontend_alb_sg.id]
  }

  # Egress anywhere (for package repos, etc.)
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = { Name = "${var.project_name}-frontend-ec2-sg", Tier = "web" }
}

############################################################
# Public ALB (internet-facing)
# - Lives in web public subnets
# - Health checks the frontend instances
############################################################
resource "aws_lb" "frontend" {
  name               = "${var.project_name}-frontend-alb"
  internal           = false
  load_balancer_type = "application"
  security_groups    = [aws_security_group.frontend_alb_sg.id]
  subnets            = var.web_public_subnet_ids

  tags = { Name = "${var.project_name}-frontend-alb", Tier = "web" }
}

resource "aws_lb_target_group" "frontend" {
  name        = "${var.project_name}-frontend-tg"
  vpc_id      = var.vpc_id
  port        = var.frontend_listen_port
  protocol    = "HTTP"
  target_type = "instance"

  health_check {
    enabled             = true
    path                = var.health_check_path
    port                = "traffic-port"
    protocol            = "HTTP"
    healthy_threshold   = 2
    unhealthy_threshold = 2
    interval            = 15
    timeout             = 5
    matcher             = "200-399"
  }

  tags = { Name = "${var.project_name}-frontend-tg", Tier = "web" }
}

resource "aws_lb_listener" "frontend_http" {
  load_balancer_arn = aws_lb.frontend.arn
  port              = var.frontend_listen_port
  protocol          = "HTTP"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.frontend.arn
  }
}

############################################################
# Launch Template
# - Uses your existing frontend AMI
# - Injects BACKEND_BASE_URL and (optionally) Nginx proxy to /api
############################################################
locals {
  frontend_user_data = templatefile("${path.module}/user_data/frontend.sh.tftpl", {
    BACKEND_DNS  = var.backend_alb_dns_name
    BACKEND_PORT = var.backend_app_port
  })
}

resource "aws_launch_template" "frontend" {
  name_prefix   = "${var.project_name}-frontend-"
  image_id      = var.frontend_ami_id
  instance_type = var.instance_type
  key_name      = var.key_name

  vpc_security_group_ids = [aws_security_group.frontend_ec2_sg.id]

  user_data = base64encode(local.frontend_user_data)

  block_device_mappings {
    device_name = "/dev/xvda"
    ebs {
      volume_size = 16
      volume_type = "gp3"
      delete_on_termination = true
    }
  }

  tag_specifications {
    resource_type = "instance"
    tags = { Name = "${var.project_name}-frontend" }
  }
}

############################################################
# Auto Scaling Group
# - Places instances in web private subnets
# - Registers instances with the frontend target group
############################################################
resource "aws_autoscaling_group" "frontend" {
  name                = "${var.project_name}-frontend-asg"
  min_size            = var.min_size
  desired_capacity    = var.desired_capacity
  max_size            = var.max_size
  vpc_zone_identifier = var.web_private_subnet_ids

  target_group_arns         = [aws_lb_target_group.frontend.arn]
  health_check_type         = "ELB"
  health_check_grace_period = 60

  launch_template {
    id      = aws_launch_template.frontend.id
    version = "$Latest"
  }

  tag {
    key                 = "Name"
    value               = "${var.project_name}-frontend"
    propagate_at_launch = true
  }
}
