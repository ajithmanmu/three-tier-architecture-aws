############################################################
# DB Subnet Group
# - Tells RDS which PRIVATE subnets (across ≥2 AZs) it can use.
############################################################
resource "aws_db_subnet_group" "this" {
  name       = "${var.project_name}-db-subnet-group"
  subnet_ids = var.db_private_subnet_ids

  tags = {
    Name = "${var.project_name}-db-subnet-group"
    Tier = "db"
  }
}

############################################################
# Security Group for RDS
# - Start locked down.
# - Optionally allow your admin_cidr for initial smoke tests.
# - Later we will add a rule to allow 5432 from the backend ASG SG.
############################################################
resource "aws_security_group" "db" {
  name        = "${var.project_name}-db-sg"
  description = "Postgres access for app backend (and temporary admin IP)"
  vpc_id      = var.vpc_id

  # Egress: allow RDS to reach AWS services (e.g., for backups/monitoring)
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "${var.project_name}-db-sg"
    Tier = "db"
  }
}

# Optional temporary ingress from your workstation (psql).
resource "aws_security_group_rule" "db_admin_ingress" {
  count             = var.admin_cidr == null ? 0 : 1
  type              = "ingress"
  security_group_id = aws_security_group.db.id
  from_port         = 5432
  to_port           = 5432
  protocol          = "tcp"
  cidr_blocks       = [var.admin_cidr]
  description       = "Temporary admin access for psql"
}

############################################################
# RDS Postgres Instance
# - Private only (no public IP).
# - Single-AZ for demo; multi_az can be toggled later.
# - Deletion protection off & skip final snapshot (demo-friendly).
############################################################
resource "aws_db_instance" "postgres" {
  identifier                  = var.db_identifier
  engine                      = "postgres"
  engine_version              = var.db_engine_version

  instance_class              = var.db_instance_class
  allocated_storage           = var.allocated_storage_gb
  storage_encrypted           = true

  db_subnet_group_name        = aws_db_subnet_group.this.name
  vpc_security_group_ids      = [aws_security_group.db.id]
  publicly_accessible         = false         # keep it private
  multi_az                    = false         # demo: single-AZ

  db_name                     = var.db_name
  username                    = var.db_username
  password                    = var.db_password

  backup_retention_period     = 0             # demo: no automated backups
  deletion_protection         = false
  skip_final_snapshot         = true          # demo: easy teardown

  # Performance/monitoring defaults are fine for now.
  apply_immediately           = true

  tags = {
    Name = "${var.project_name}-rds"
    Tier = "db"
  }
}
