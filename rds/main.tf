#################################
# NETWORKING
#################################

# RDS master subnet
resource "aws_subnet" "rds_master" {
  vpc_id     = var.vpc_id
  cidr_block = var.rds_master_subnet_cidr

  tags = {
    Name = "${var.project}-rds-master-subnet"
  }
}

# First RDS replica subnet
resource "aws_subnet" "rds_replica1" {
  vpc_id            = var.vpc_id
  cidr_block        = var.rds_replica1_subnet_cidr
  availability_zone = "eu-north-1a"

  tags = {
    Name = "${var.project}-rds-replica1-subnet"
  }
}

# Second RDS replica subnet
resource "aws_subnet" "rds_replica2" {
  vpc_id            = var.vpc_id
  cidr_block        = var.rds_replica2_subnet_cidr
  availability_zone = "eu-north-1b"

  tags = {
    Name = "${var.project}-rds-replica2-subnet"
  }
}

# Create a DB subnet group for RDS
resource "aws_db_subnet_group" "rds_subnet_group" {
  name       = "${var.project}-rds-subnet-group"
  subnet_ids = [aws_subnet.rds_master.id, aws_subnet.rds_replica1.id, aws_subnet.rds_replica2.id]

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

#Multi-AZ PostgreSQL RDS instance
resource "aws_db_instance" "rds_instance" {
  identifier                  = "${var.project}-rds-instance"
  allocated_storage           = 20
  engine                      = "postgres"
  engine_version              = "18.0"
  instance_class              = var.rds_instance_type
  manage_master_user_password = true
  skip_final_snapshot         = true
  db_subnet_group_name        = aws_db_subnet_group.rds_subnet_group.name
  vpc_security_group_ids      = [aws_security_group.rds_sg.id]
  multi_az                    = true
  publicly_accessible         = false

  tags = {
    Name = "${var.project}-rds-instance"
  }
}
