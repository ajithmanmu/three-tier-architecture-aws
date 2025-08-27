# ---------- Shared/environment inputs ----------
variable "aws_region"   { type = string }
variable "project_name" { type = string }

# ---------- From Phase 1 (network) ----------
# Paste these from the network outputs (not data sources, to keep steps independent).
variable "vpc_id" {
  description = "VPC where RDS will live (from network outputs)"
  type        = string
}
variable "db_private_subnet_ids" {
  description = "List of 3 private DB subnet IDs (from network outputs)"
  type        = list(string)
}

# ---------- DB parameters ----------
variable "db_identifier" { type = string }         # e.g., "three-tier-app-db"
variable "db_name"       { type = string }         # e.g., "streetair"
variable "db_username"   { type = string }         # e.g., "app_user"
variable "db_password"   { type = string }         # mark sensitive in tfvars

variable "db_engine_version" {
  description = "PostgreSQL engine version"
  type        = string
  default     = "15.4"
}

variable "db_instance_class" {
  description = "RDS instance class"
  type        = string
  default     = "db.t3.micro"
}

variable "allocated_storage_gb" {
  description = "Storage in GB"
  type        = number
  default     = 20
}

# For initial smoke tests: allow psql from your workstation. Later we’ll restrict to backend SG.
variable "admin_cidr" {
  description = "Temporary CIDR allowed to reach Postgres (e.g., your IP/32). Set to null to disable."
  type        = string
  default     = null
}
