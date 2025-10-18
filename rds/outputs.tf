output "rds_endpoint" {
  value       = aws_db_instance.rds_instance.endpoint
  description = "Endpoint of the RDS instance"
}
