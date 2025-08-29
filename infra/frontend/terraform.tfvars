aws_region   = "us-east-1"
project_name = "three-tier-app"

# ---- Paste from network outputs ----
vpc_id                 = "vpc-0e676555b67a7954b"
web_public_subnet_ids  = [
  "subnet-03273573fdcf607e9",
  "subnet-09a1cce72d52923bc",
  "subnet-087bb4e80e4e76de5"
]
web_private_subnet_ids = [
  "subnet-03a7cee8cb6fd7c4f",
  "subnet-084d8ce6c2ff87833",
  "subnet-0a9f46b2c633cf3b6"
]

# ---- Paste from backend outputs/vars ----
backend_alb_dns_name = "internal-three-tier-app-backend-alb-2143321733.us-east-1.elb.amazonaws.com"
backend_app_port     = 8000  # must match the backend app_port you settled on

# ---- Your existing frontend AMI ----
frontend_ami_id = "ami-05e60bdf28cfd018e"

# ---- App / capacity ----
frontend_listen_port = 80       # typical Nginx/static
health_check_path    = "/"
desired_capacity     = 1
min_size             = 1
max_size             = 1

# key_name = "optional-ec2-keypair"
