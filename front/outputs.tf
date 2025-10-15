output "sg_id" {
  value       = aws_security_group.sg.id
  description = "Security group ID for the EC2 instance"
}
