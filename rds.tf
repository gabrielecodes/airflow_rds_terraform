#################################
# NETWORKING
#################################

# RDS master subnet
resource "aws_subnet" "rds_master" {
  vpc_id            = aws_vpc.main.id
  cidr_block        = var.rds_master_subnet_cidr
  availability_zone = "${var.region}a"

  tags = {
    Name = "${var.project}-rds-master-subnet"
  }
}

resource "aws_subnet" "rds_master_b" {
  vpc_id            = aws_vpc.main.id
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
  vpc_id      = aws_vpc.main.id

  ingress {
    from_port       = 5432
    to_port         = 5432
    protocol        = "tcp"
    security_groups = [aws_security_group.sg.id]
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

# Store the postgres connection so Airflow dags can connect to postgres
resource "aws_ssm_parameter" "airflow_postgres_conn" {
  name = "/airflow/connections/postgres_url"
  type = "SecureString"

  # {schema}://{login}:{password}@{host}:{port}/{database_name}
  value = "postgresql://${var.rds_username}:${var.rds_password}@${aws_db_instance.rds_instance.address}:5432/postgres"

  description = "Airflow Connection URI"
}
