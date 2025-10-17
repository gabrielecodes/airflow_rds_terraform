output "sg_id" {
  value       = aws_security_group.sg.id
  description = "Security group ID for the EC2 instance"
}

output "airflow_public_ip" {
  value       = aws_instance.airflow.public_ip
  description = "Public IP address of the Airflow EC2 instance"
}
