# Public URL for your app
output "frontend_alb_dns_name" {
  value = aws_lb.frontend.dns_name
}

# Useful SG IDs (optional)
output "frontend_ec2_sg_id" {
  value = aws_security_group.frontend_ec2_sg.id
}
output "frontend_alb_sg_id" {
  value = aws_security_group.frontend_alb_sg.id
}
