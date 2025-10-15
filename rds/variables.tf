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

variable "rds_replica1_subnet_cidr" {
  type        = string
  description = "rds replica1 subnet cidr"
}

variable "rds_replica2_subnet_cidr" {
  type        = string
  description = "rds replica2 subnet cidr"
}

variable "front_sg_id" {
  description = "Security group ID for Airflow"
  type        = string
}
