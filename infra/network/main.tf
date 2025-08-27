############################################################
# Locals
# - Capture AZs from subnet maps (so we can reference them later).
# - Choose an AZ for the NAT Gateway (defaults to first public AZ).
############################################################
locals {
  azs_web_public   = keys(var.web_public_subnets)   # AZ list for public web subnets
  azs_web_private  = keys(var.web_private_subnets)  # AZ list for private web (frontend EC2)
  azs_app_private  = keys(var.app_private_subnets)  # AZ list for private app (backend EC2)
  azs_db_private   = keys(var.database_subnets)     # AZ list for private DB subnets

  nat_az = coalesce(var.nat_gateway_az, try(local.azs_web_public[0], null))
}

############################################################
# VPC
# - The main network container for all subnets, IGW, NAT, and route tables.
############################################################
resource "aws_vpc" "main" {
  cidr_block           = var.vpc_cidr
  enable_dns_support   = true        # allow DNS resolution inside VPC
  enable_dns_hostnames = true        # assign DNS hostnames to instances
  tags = { Name = "${var.project_name}-vpc" }
}

############################################################
# Subnets
# - Four categories, spread across 3 AZs each:
#   1. web_public: ALBs live here (public IPs).
#   2. web_private: frontend EC2s (no public IPs).
#   3. app_private: backend EC2s (no public IPs).
#   4. db_private: RDS subnets (no public IPs).
############################################################
resource "aws_subnet" "web_public" {
  for_each                = var.web_public_subnets
  vpc_id                  = aws_vpc.main.id
  cidr_block              = each.value
  availability_zone       = each.key
  map_public_ip_on_launch = true     # public IPs auto-assigned to instances

  tags = {
    Name = "${var.project_name}-web-public-${substr(each.key, -1, 1)}"
    Tier = "web-public"
    AZ   = each.key
  }
}

resource "aws_subnet" "web_private" {
  for_each          = var.web_private_subnets
  vpc_id            = aws_vpc.main.id
  cidr_block        = each.value
  availability_zone = each.key

  tags = {
    Name = "${var.project_name}-web-private-${substr(each.key, -1, 1)}"
    Tier = "web-private"
    AZ   = each.key
  }
}

resource "aws_subnet" "app_private" {
  for_each          = var.app_private_subnets
  vpc_id            = aws_vpc.main.id
  cidr_block        = each.value
  availability_zone = each.key

  tags = {
    Name = "${var.project_name}-app-private-${substr(each.key, -1, 1)}"
    Tier = "app"
    AZ   = each.key
  }
}

resource "aws_subnet" "db_private" {
  for_each          = var.database_subnets
  vpc_id            = aws_vpc.main.id
  cidr_block        = each.value
  availability_zone = each.key

  tags = {
    Name = "${var.project_name}-db-private-${substr(each.key, -1, 1)}"
    Tier = "db"
    AZ   = each.key
  }
}

############################################################
# Internet Gateway (IGW)
# - Provides internet access to resources in public subnets.
############################################################
resource "aws_internet_gateway" "igw" {
  vpc_id = aws_vpc.main.id
  tags = { Name = "${var.project_name}-igw" }
}

############################################################
# NAT Gateway
# - Single NAT Gateway (in one public subnet).
# - Lets private subnets reach the internet (for updates, packages).
############################################################
resource "aws_eip" "nat" {
  domain = "vpc"
  tags = { Name = "${var.project_name}-nat-eip" }
}

resource "aws_nat_gateway" "nat" {
  allocation_id = aws_eip.nat.id
  subnet_id     = aws_subnet.web_public[local.nat_az].id  # put NAT in chosen public AZ
  depends_on    = [aws_internet_gateway.igw]
  tags = { Name = "${var.project_name}-nat" }
}

############################################################
# Route Tables
# - One per tier: public, web_private, app_private, db_private.
# - Public → IGW; all Private → NAT Gateway.
############################################################
resource "aws_route_table" "public" {
  vpc_id = aws_vpc.main.id
  tags   = { Name = "${var.project_name}-rtb-public" }
}

resource "aws_route" "public_default" {
  route_table_id         = aws_route_table.public.id
  destination_cidr_block = "0.0.0.0/0"
  gateway_id             = aws_internet_gateway.igw.id
}

resource "aws_route_table" "web_private" {
  vpc_id = aws_vpc.main.id
  tags   = { Name = "${var.project_name}-rtb-web-private" }
}
resource "aws_route" "web_private_default" {
  route_table_id         = aws_route_table.web_private.id
  destination_cidr_block = "0.0.0.0/0"
  nat_gateway_id         = aws_nat_gateway.nat.id
}

resource "aws_route_table" "app_private" {
  vpc_id = aws_vpc.main.id
  tags   = { Name = "${var.project_name}-rtb-app-private" }
}
resource "aws_route" "app_private_default" {
  route_table_id         = aws_route_table.app_private.id
  destination_cidr_block = "0.0.0.0/0"
  nat_gateway_id         = aws_nat_gateway.nat.id
}

resource "aws_route_table" "db_private" {
  vpc_id = aws_vpc.main.id
  tags   = { Name = "${var.project_name}-rtb-db-private" }
}
resource "aws_route" "db_private_default" {
  route_table_id         = aws_route_table.db_private.id
  destination_cidr_block = "0.0.0.0/0"
  nat_gateway_id         = aws_nat_gateway.nat.id
}

############################################################
# Route Table Associations
# - Tie each subnet to the correct RTB.
#   * web_public → public RTB
#   * web_private → web_private RTB
#   * app_private → app_private RTB
#   * db_private → db_private RTB
############################################################
resource "aws_route_table_association" "assoc_web_public" {
  for_each       = aws_subnet.web_public
  subnet_id      = each.value.id
  route_table_id = aws_route_table.public.id
}

resource "aws_route_table_association" "assoc_web_private" {
  for_each       = aws_subnet.web_private
  subnet_id      = each.value.id
  route_table_id = aws_route_table.web_private.id
}

resource "aws_route_table_association" "assoc_app_private" {
  for_each       = aws_subnet.app_private
  subnet_id      = each.value.id
  route_table_id = aws_route_table.app_private.id
}

resource "aws_route_table_association" "assoc_db_private" {
  for_each       = aws_subnet.db_private
  subnet_id      = each.value.id
  route_table_id = aws_route_table.db_private.id
}
