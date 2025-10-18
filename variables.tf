variable "region" {
  description = "AWS region"
  type        = string
  default     = "eu-north-1"
}

variable "project" {
  description = "Project name"
  type        = string
  default     = "airflow-rds"
}

variable "vpc_cidr" {
  description = "The CIDR block for the VPC"
  type        = string
  default     = "10.0.0.0/16"
}

variable "instance_type" {
  description = "EC2 Instance type"
  type        = string
  default     = "t3.large"
}

variable "public_subnet_cidr" {
  type        = string
  description = "CIDR for public subnet"
  default     = "10.0.1.0/24"
}

variable "rds_instance_type" {
  description = "Instance type for RDS"
  type        = string
  default     = "db.t3.micro"
}

variable "rds_master_subnet_cidr" {
  type        = string
  description = "rds master subnet cidr"
  default     = "10.0.2.0/24"
}

variable "rds_master_subnet_cidr_b" {
  type        = string
  description = "rds secondary master subnet cidr in different AZ"
  default     = "10.0.3.0/24"
}

variable "rds_username" {
  type        = string
  description = "RDS database username"
}

variable "rds_password" {
  type        = string
  description = "RDS database password"
}

variable "airflow_username" {
  description = "Airflow UI login username"
  type        = string
}

variable "airflow_password" {
  description = "Airflow UI login password"
  type        = string
}

variable "dags_bucket" {
  description = "S3 bucket name for Airflow DAGs"
  type        = string
}

variable "ec2_key" {
  description = "EC2 Key Pair name"
  type        = string
}

variable "account_id" {
  description = "AWS Account ID"
  type        = string
}
