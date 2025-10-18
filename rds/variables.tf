variable "region" {
  description = "AWS region"
  type        = string
}

variable "project" {
  description = "Project name"
  type        = string
}

variable "vpc_id" {
  description = "The id VPC"
  type        = string
}

variable "rds_instance_type" {
  type        = string
  description = "RDS instance type"
}

variable "rds_master_subnet_cidr" {
  type        = string
  description = "rds master subnet cidr"
}

variable "rds_master_subnet_cidr_b" {
  type        = string
  description = "rds secondary master subnet cidr in different AZ"
}

variable "front_sg_id" {
  description = "Security group ID for Airflow"
  type        = string
}

variable "rds_username" {
  description = "RDS database username"
  type        = string
}

variable "rds_password" {
  description = "RDS database password"
  type        = string
}
