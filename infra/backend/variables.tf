############################################
# Environment
############################################
variable "aws_region" { type = string }
variable "project_name" { type = string }

############################################
# From Phase 1 (network)
############################################
variable "vpc_id" {
  description = "VPC ID from the network step output"
  type        = string
}
variable "app_private_subnet_ids" {
  description = "List of 3 private app subnet IDs (from network outputs)"
  type        = list(string)
}

############################################
# From Phase 2 (database)
############################################
variable "db_security_group_id" {
  description = "DB SG ID (so we can allow 5432 from backend instances)"
  type        = string
}
variable "db_endpoint" { type = string } # e.g., demo-db.xxxxxx.rds.amazonaws.com
variable "db_name" { type = string }
variable "db_username" { type = string }
variable "db_password" { type = string } # demo only; in state

############################################
# AMI / EC2 / App settings
############################################
variable "backend_ami_id" {
  description = "Existing baked AMI for backend"
  type        = string
}
variable "instance_type" {
  description = "EC2 size for backend"
  type        = string
  default     = "t3.micro"
}
variable "app_port" {
  description = "Backend service port (ALB target + health check)"
  type        = number
  default     = 5000
}
variable "health_check_path" {
  description = "Path the ALB uses to check instance health"
  type        = string
  default     = "/health"
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
