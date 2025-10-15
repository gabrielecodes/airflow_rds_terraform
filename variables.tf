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
  default     = "t3.micro"
}

variable "public_subnet_cidr" {
  type        = string
  description = "CIDR for public subnet"
  default     = "10.0.1.0/24"
}

variable "rds_instance_type" {
  description = "Instance type for RDS"
  type        = string
  default     = "t3.micro"
}

variable "rds_master_subnet_cidr" {
  type        = string
  description = "rds master subnet cidr"
  default     = "10.0.2.0/24"
}

variable "rds_replica1_subnet_cidr" {
  type        = string
  description = "rds replica1 subnet cidr"
  default     = "10.0.3.0/24"
}

variable "rds_replica2_subnet_cidr" {
  type        = string
  description = "rds replica2 subnet cidr"
  default     = "10.0.4.0/24"
}
