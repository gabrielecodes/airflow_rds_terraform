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

variable "instance_type" {
  description = "EC2 Instance type"
  type        = string
}

variable "public_subnet_cidr" {
  description = "CIDR for public subnet"
  type        = string
}

variable "airflow_username" {
  description = "Airflow UI login username"
  type        = string
}

variable "airflow_password" {
  description = "Airflow UI login password"
  type        = string
}

variable "ec2_key" {
  description = "SSH key pair name for EC2 instance"
  type        = string
}

variable "rds_username" {
  description = "RDS master username for the Airflow DBT connection"
  type        = string
}
