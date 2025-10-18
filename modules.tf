module "airflow" {
  source = "./airflow"

  account_id         = var.account_id
  project            = var.project
  region             = var.region
  vpc_id             = aws_vpc.main.id
  public_subnet_cidr = var.public_subnet_cidr
  instance_type      = var.instance_type
  airflow_username   = var.airflow_username
  airflow_password   = var.airflow_password
  ec2_key            = var.ec2_key
  rds_endpoint       = module.rds.rds_endpoint
  dags_bucket        = var.dags_bucket
}

module "rds" {
  source = "./rds"

  project                  = var.project
  region                   = var.region
  vpc_id                   = aws_vpc.main.id
  rds_instance_type        = var.rds_instance_type
  rds_master_subnet_cidr   = var.rds_master_subnet_cidr
  rds_master_subnet_cidr_b = var.rds_master_subnet_cidr_b
  rds_username             = var.rds_username
  rds_password             = var.rds_password
  front_sg_id              = module.airflow.sg_id
}
