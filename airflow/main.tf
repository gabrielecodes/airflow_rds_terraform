##################################
# NETWORKING
##################################

# Public subnet
resource "aws_subnet" "public" {
  vpc_id                  = var.vpc_id
  cidr_block              = var.public_subnet_cidr
  map_public_ip_on_launch = true
}

# Get the IP address of this machine
data "http" "my_ip" {
  url = "https://api.ipify.org"
}

locals {
  my_ip_cidr = "${chomp(data.http.my_ip.response_body)}/32"
}

# Security Group
resource "aws_security_group" "sg" {
  name        = "test-sg"
  description = "Allow SSH to my IP and web access"
  vpc_id      = var.vpc_id

  ingress {
    description = "Inbound SSH"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = [local.my_ip_cidr]
  }

  ingress {
    description = "Inbound Web UI access"
    from_port   = 8080
    to_port     = 8080
    protocol    = "tcp"
    cidr_blocks = [local.my_ip_cidr]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "${var.project}-airflow-sg"
  }
}

# Internet Gateway
resource "aws_internet_gateway" "igw" {
  vpc_id = var.vpc_id

  tags = {
    Name = "${var.project}-igw"
  }
}

# Public route table
resource "aws_route_table" "public_rt" {
  vpc_id = var.vpc_id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.igw.id
  }
}

# Associate the public subnet with the public route table
resource "aws_route_table_association" "public_rt_assoc" {
  subnet_id      = aws_subnet.public.id
  route_table_id = aws_route_table.public_rt.id
}

##################################
# INSTANCE
##################################

resource "aws_key_pair" "terraform_ec2_key" {
  key_name   = "terraform_ec2_key"
  public_key = file("terraform_ec2_key.pub")
}

# Retrieve RDS master password from Secrets Manager
data "aws_secretsmanager_secret" "rds_master_user_secret" {
  arn = aws_db_instance.rds_instance.master_user_secret[0].secret_arn
}

data "aws_secretsmanager_secret_version" "rds_master_password_version" {
  secret_id = data.aws_secretsmanager_secret.rds_master_user_secret.id
}

# Retrieve RDS endpoint from SSM Parameter Store
data "aws_ssm_parameter" "rds_endpoint" {
  name = "/${var.project}/rds/endpoint"
}

# Airflow instance
resource "aws_instance" "airflow" {
  ami                    = "ami-0393c82ef8ecfdbed"
  instance_type          = var.instance_type
  key_name               = var.ec2_key
  vpc_security_group_ids = [aws_security_group.sg.id]
  subnet_id              = aws_subnet.public.id

  user_data = templatefile("${path.root}/cloud-init.yaml", {
    airflow_username = var.airflow_username
    airflow_password = var.airflow_password
    rds_username     = var.rds_username
    rds_password     = data.aws_secretsmanager_secret_version.rds_master_password_version.secret_string
    rds_endpoint     = data.aws_ssm_parameter.rds_endpoint.value
  })

  root_block_device {
    volume_size           = 20
    volume_type           = "gp3"
    delete_on_termination = true
  }

  tags = {
    Name = "${var.project}-airflow-instance"
  }

  depends_on = [
    aws_db_instance.rds_instance
  ]
}
