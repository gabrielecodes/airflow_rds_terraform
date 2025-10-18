#################################
# NETWORKING
#################################

# RDS master subnet
resource "aws_subnet" "rds_master" {
  vpc_id            = var.vpc_id
  cidr_block        = var.rds_master_subnet_cidr
  availability_zone = "${var.region}a"

  tags = {
    Name = "${var.project}-rds-master-subnet"
  }
}

resource "aws_subnet" "rds_master_b" {
  vpc_id            = var.vpc_id
  cidr_block        = var.rds_master_subnet_cidr_b
  availability_zone = "${var.region}b"

  tags = {
    Name = "${var.project}-rds-master-subnet-b"
  }
}

# Create a DB subnet group for RDS
resource "aws_db_subnet_group" "rds_subnet_group" {
  name       = "${var.project}-rds-subnet-group"
  subnet_ids = [aws_subnet.rds_master.id, aws_subnet.rds_master_b.id]

  tags = {
    Name = "${var.project}-rds-subnet-group"
  }
}

# Secruity group for RDS allowing access from the public subnet
resource "aws_security_group" "rds_sg" {
  name        = "${var.project}-rds-sg"
  description = "Allow Postgres access from public subnet"
  vpc_id      = var.vpc_id

  ingress {
    from_port       = 5432
    to_port         = 5432
    protocol        = "tcp"
    security_groups = [var.front_sg_id]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "${var.project}-rds-sg"
  }
}

#################################
# INSTANCE
#################################

# RDS instance
resource "aws_db_instance" "rds_instance" {
  identifier             = "${var.project}-rds-instance"
  allocated_storage      = 20
  engine                 = "postgres"
  engine_version         = "17.4"
  instance_class         = var.rds_instance_type
  username               = var.rds_username
  password               = var.rds_password
  skip_final_snapshot    = true
  db_subnet_group_name   = aws_db_subnet_group.rds_subnet_group.name
  vpc_security_group_ids = [aws_security_group.rds_sg.id]
  multi_az               = false
  publicly_accessible    = false

  tags = {
    Name = "${var.project}-rds-instance"
  }
}

# Store RDS endpoint in SSM Parameter Store
resource "aws_ssm_parameter" "rds_endpoint" {
  name        = "/airflow/variables/rds_endpoint"
  type        = "SecureString"
  value       = aws_db_instance.rds_instance.address
  description = "RDS endpoint for ${var.project}"
}

# Store RDS username in SSM Parameter Store
resource "aws_ssm_parameter" "rds_username" {
  name        = "/airflow/variables/rds_username"
  type        = "SecureString"
  value       = var.rds_username
  description = "RDS username for ${var.project}"
}

# Store RDS username in SSM Parameter Store
resource "aws_ssm_parameter" "rds_password" {
  name        = "/airflow/variables/rds_password"
  type        = "SecureString"
  value       = var.rds_password
  description = "RDS password for ${var.project}"
}
