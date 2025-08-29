aws_region   = "us-east-1"
project_name = "three-tier-app"

# ---- Paste from network outputs ----
vpc_id = "vpc-0e676555b67a7954b"
app_private_subnet_ids = [
  "subnet-04d7e9d5e44e13ac3",
  "subnet-09f141a25dc0bc70b",
  "subnet-0e3bbbd4c39c36218"
]

# ---- Paste from database outputs/inputs ----
db_security_group_id = "sg-05dadce354d60b962"
db_endpoint          = "three-tier-app-db.c8z60a6g844c.us-east-1.rds.amazonaws.com"
db_name              = "items"
db_username          = "app_user"
db_password          = "CHANGE_ME_demo_only"

# ---- Your existing backend AMI ----
backend_ami_id = "ami-0ba566c66f60c3df0"

# ---- App / capacity ----
app_port          = 8000
health_check_path = "/health"
desired_capacity  = 1
min_size          = 1
max_size          = 2

# key_name = "optional-ec2-keypair"
