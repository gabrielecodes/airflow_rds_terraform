module "airflow" {
  source = "./front"

  project            = var.project
  region             = var.region
  vpc_id             = aws_vpc.main.id
  public_subnet_cidr = var.public_subnet_cidr
  instance_type      = var.instance_type
}

module "rds_instance" {
  source = "./rds"

  project                  = var.project
  region                   = var.region
  vpc_id                   = aws_vpc.main.id
  rds_instance_type        = var.rds_instance_type
  rds_master_subnet_cidr   = var.rds_master_subnet_cidr
  rds_replica1_subnet_cidr = var.rds_replica1_subnet_cidr
  rds_replica2_subnet_cidr = var.rds_replica2_subnet_cidr
  front_sg_id              = module.airflow.sg_id
}
