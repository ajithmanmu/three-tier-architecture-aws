# This DNS name is needed by the FRONTEND tier to call the backend
output "backend_alb_dns_name" {
  value = aws_lb.backend.dns_name
}

# Useful SG IDs if you want to reference them later
output "backend_ec2_sg_id" {
  value = aws_security_group.backend_ec2_sg.id
}
output "backend_alb_sg_id" {
  value = aws_security_group.backend_alb_sg.id
}
