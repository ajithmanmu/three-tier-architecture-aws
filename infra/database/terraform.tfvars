aws_region   = "us-east-1"
project_name = "three-tier-app"

# ---- Paste from network step outputs ----
vpc_id                   = "vpc-0e676555b67a7954b"
db_private_subnet_ids    = [
  "subnet-03c2e9dc5527839d7",
  "subnet-0b7f3bce821b65be7",
  "subnet-08912a85ed973fa72"
]

# ---- Database settings ----
db_identifier       = "three-tier-app-db"
db_name             = "streetair"
db_username         = "app_user"
db_password         = "CHANGE_ME_demo_only"  # demo only; will live in TF state

db_engine_version   = "15.4"
db_instance_class   = "db.t3.micro"
allocated_storage_gb = 20

# Optionally allow your laptop while bootstrapping (replace with your IP/32 or leave null)
admin_cidr          = "47.155.54.222/32"
