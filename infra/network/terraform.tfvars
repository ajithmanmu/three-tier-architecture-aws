aws_region   = "us-east-1"
project_name = "three-tier-app"
vpc_cidr     = "10.0.0.0/16"

web_public_subnets = {
  "us-east-1a" = "10.0.0.0/20"
  "us-east-1b" = "10.0.16.0/20"
  "us-east-1c" = "10.0.32.0/20"
}

web_private_subnets = {
  "us-east-1a" = "10.0.48.0/20"
  "us-east-1b" = "10.0.64.0/20"
  "us-east-1c" = "10.0.80.0/20"
}

app_private_subnets = {
  "us-east-1a" = "10.0.96.0/20"
  "us-east-1b" = "10.0.112.0/20"
  "us-east-1c" = "10.0.128.0/20"
}

database_subnets = {
  "us-east-1a" = "10.0.144.0/20"
  "us-east-1b" = "10.0.160.0/20"
  "us-east-1c" = "10.0.176.0/20"
}

# Optional: pin NAT to a specific AZ; if omitted, code will pick the first key of web_public_subnets
nat_gateway_az = "us-east-1a"
