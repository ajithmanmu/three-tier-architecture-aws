############################################
# Environment
############################################
variable "aws_region"   { type = string }
variable "project_name" { type = string }

############################################
# From Phase 1 (network)
############################################
variable "vpc_id" {
  description = "VPC ID from the network step output"
  type        = string
}
variable "web_public_subnet_ids" {
  description = "3 public web subnets for the public ALB"
  type        = list(string)
}
variable "web_private_subnet_ids" {
  description = "3 private web subnets for the frontend ASG"
  type        = list(string)
}

############################################
# From Phase 3 (backend)
############################################
variable "backend_alb_dns_name" {
  description = "Internal backend ALB DNS (used by frontend to reach API)"
  type        = string
}
variable "backend_app_port" {
  description = "Backend service port (must match backend app_port)"
  type        = number
  default     = 8000
}

############################################
# AMI / EC2 / App
############################################
variable "frontend_ami_id" {
  description = "Existing baked AMI for frontend"
  type        = string
}
variable "instance_type" {
  description = "EC2 size for frontend"
  type        = string
  default     = "t3.micro"
}
variable "frontend_listen_port" {
  description = "Port the frontend instances listen on (Nginx/static)"
  type        = number
  default     = 80
}
variable "health_check_path" {
  description = "ALB health check path"
  type        = string
  default     = "/"
}

############################################
# Capacity
############################################
variable "desired_capacity" {
  type    = number
  default = 1
}

variable "min_size" {
  type    = number
  default = 1
}

variable "max_size" {
  type    = number
  default = 1
}

############################################
# (Optional) SSH key for debugging
############################################
variable "key_name" {
  description = "EC2 key pair name (optional)"
  type        = string
  default     = null
}
