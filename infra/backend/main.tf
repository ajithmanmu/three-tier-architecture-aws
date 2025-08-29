############################################################
# Security Groups
# - backend_alb_sg: allows inbound HTTP from VPC (temporary).
#   Later we’ll restrict to frontend_asg_sg once frontend exists.
# - backend_ec2_sg: allows inbound from backend ALB only.
############################################################
resource "aws_security_group" "backend_alb_sg" {
  name        = "${var.project_name}-backend-alb-sg"
  description = "Ingress to internal backend ALB"
  vpc_id      = var.vpc_id

  # TEMP: allow HTTP from VPC CIDR (least friction during bring-up)
  # After frontend exists, replace with source_security_group_id = frontend_asg_sg.id
  ingress {
    description = "HTTP from VPC (temporary; tighten later)"
    from_port   = var.app_port
    to_port     = var.app_port
    protocol    = "tcp"
    cidr_blocks = ["10.0.0.0/16"] # your VPC CIDR; adjust if different
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = { Name = "${var.project_name}-backend-alb-sg", Tier = "app" }
}

resource "aws_security_group" "backend_ec2_sg" {
  name        = "${var.project_name}-backend-ec2-sg"
  description = "Backend instances"
  vpc_id      = var.vpc_id

  # Ingress ONLY from the backend ALB SG on app port
  ingress {
    description     = "App traffic from backend ALB"
    from_port       = var.app_port
    to_port         = var.app_port
    protocol        = "tcp"
    security_groups = [aws_security_group.backend_alb_sg.id]
  }

  # Egress anywhere (for package repos, etc.)
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = { Name = "${var.project_name}-backend-ec2-sg", Tier = "app" }
}

############################################################
# DB SG Rule
# - Let backend instances talk to Postgres on 5432.
# - This updates the DB SG you created in Phase 2.
############################################################
resource "aws_security_group_rule" "db_from_backend" {
  type                     = "ingress"
  security_group_id        = var.db_security_group_id # RDS SG
  from_port                = 5432
  to_port                  = 5432
  protocol                 = "tcp"
  source_security_group_id = aws_security_group.backend_ec2_sg.id
  description              = "Allow Postgres from backend instances"
}

############################################################
# Internal ALB (private)
# - Lives in app private subnets.
# - Receives traffic from frontend tier.
############################################################
resource "aws_lb" "backend" {
  name               = "${var.project_name}-backend-alb"
  internal           = true
  load_balancer_type = "application"
  security_groups    = [aws_security_group.backend_alb_sg.id]
  subnets            = var.app_private_subnet_ids

  tags = { Name = "${var.project_name}-backend-alb", Tier = "app" }
}

resource "aws_lb_target_group" "backend" {
  name        = "${var.project_name}-backend-tg"
  vpc_id      = var.vpc_id
  port        = var.app_port
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

  tags = { Name = "${var.project_name}-backend-tg", Tier = "app" }
}

resource "aws_lb_listener" "backend_http" {
  load_balancer_arn = aws_lb.backend.arn
  port              = var.app_port
  protocol          = "HTTP"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.backend.arn
  }
}

############################################################
# Launch Template
# - Uses your existing backend AMI.
# - Injects DB settings into /etc/myapp/backend.env via user_data.
############################################################
locals {
  backend_user_data = templatefile("${path.module}/user_data/backend.sh.tftpl", {
    DB_HOST     = var.db_endpoint
    DB_NAME     = var.db_name
    DB_USER     = var.db_username
    DB_PASSWORD = var.db_password
    APP_PORT    = var.app_port
  })
}

resource "aws_launch_template" "backend" {
  name_prefix   = "${var.project_name}-backend-"
  image_id      = var.backend_ami_id
  instance_type = var.instance_type
  key_name      = var.key_name

  vpc_security_group_ids = [aws_security_group.backend_ec2_sg.id]

  user_data = base64encode(local.backend_user_data)

  # (Optional) small root volume
  block_device_mappings {
    device_name = "/dev/xvda"
    ebs {
      volume_size           = 16
      volume_type           = "gp3"
      delete_on_termination = true
    }
  }

  tag_specifications {
    resource_type = "instance"
    tags          = { Name = "${var.project_name}-backend" }
  }
}

############################################################
# Auto Scaling Group
# - Places instances in app private subnets.
# - Registers instances with the backend target group.
############################################################
resource "aws_autoscaling_group" "backend" {
  name                = "${var.project_name}-backend-asg"
  min_size            = var.min_size
  desired_capacity    = var.desired_capacity
  max_size            = var.max_size
  vpc_zone_identifier = var.app_private_subnet_ids

  target_group_arns         = [aws_lb_target_group.backend.arn]
  health_check_type         = "ELB"
  health_check_grace_period = 60

  launch_template {
    id      = aws_launch_template.backend.id
    version = "$Latest"
  }

  # Spread across AZs
  availability_zones = null # derived from subnets

  tag {
    key                 = "Name"
    value               = "${var.project_name}-backend"
    propagate_at_launch = true
  }
}
