# RDS endpoint hostname you’ll put into the backend Launch Template user_data.
output "db_endpoint" {
  value = aws_db_instance.postgres.address
}

# Full connection string helper (omit password for safety if you prefer).
output "db_url_example" {
  value = "postgresql://${var.db_username}:<PASSWORD>@${aws_db_instance.postgres.address}:5432/${var.db_name}"
  sensitive = true
}

# Useful IDs for wiring security later (backend SG rule).
output "db_security_group_id" {
  value = aws_security_group.db.id
}
