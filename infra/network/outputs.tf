output "vpc_id" {
  value = aws_vpc.main.id
}

output "web_public_subnet_ids" {
  value = [for k, s in aws_subnet.web_public  : s.id]
}

output "web_private_subnet_ids" {
  value = [for k, s in aws_subnet.web_private : s.id]
}

output "app_private_subnet_ids" {
  value = [for k, s in aws_subnet.app_private : s.id]
}

output "db_private_subnet_ids" {
  value = [for k, s in aws_subnet.db_private  : s.id]
}

output "igw_id" {
  value = aws_internet_gateway.igw.id
}

output "nat_gateway_id" {
  value = aws_nat_gateway.nat.id
}
