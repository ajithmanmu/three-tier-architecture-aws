variable "aws_region" {
  type        = string
  description = "AWS region to deploy into"
}

variable "project_name" {
  type        = string
  description = "Project tag/name"
}

variable "vpc_cidr" {
  type        = string
  description = "VPC CIDR block"
}

# Each map key must be an AZ like "us-east-1a", value is the subnet CIDR in that AZ.
variable "web_public_subnets" {
  type = map(string)
  description = "Map of AZ => CIDR for Web Public subnets"
}
variable "web_private_subnets" {
  type = map(string)
  description = "Map of AZ => CIDR for Web Private subnets"
}
variable "app_private_subnets" {
  type = map(string)
  description = "Map of AZ => CIDR for App Private subnets"
}
variable "database_subnets" {
  type = map(string)
  description = "Map of AZ => CIDR for DB Private subnets"
}

variable "nat_gateway_az" {
  type        = string
  description = "AZ to place the single NAT gateway"
  default     = null
}