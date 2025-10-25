##################################
# NETWORKING
##################################

# Public subnet
resource "aws_subnet" "public" {
  vpc_id                  = aws_vpc.main.id
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
  vpc_id      = aws_vpc.main.id

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
  vpc_id = aws_vpc.main.id

  tags = {
    Name = "${var.project}-igw"
  }
}

# Public route table
resource "aws_route_table" "public_rt" {
  vpc_id = aws_vpc.main.id

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

# Create role for the Ec2 instace
resource "aws_iam_role" "ec2_instance_role" {
  name = "${var.project}-ec2-instance-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Principal = {
          Service = "ec2.amazonaws.com"
        }
      },
    ]
  })
}

# Create instance profile for the EC2 instance
resource "aws_iam_instance_profile" "ec2_instance_profile" {
  name = "${var.project}-ec2-instance-profile"
  role = aws_iam_role.ec2_instance_role.name
}

# Attach S3 read only policy to the EC2 instance role
resource "aws_iam_role_policy_attachment" "ec2_instance_role_attachment" {
  role       = aws_iam_role.ec2_instance_role.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonS3ReadOnlyAccess"
}

# Read username, password and endpoint from SSM
# resource "aws_iam_policy" "ssm_read_limited" {
#   name        = "${var.project}-ssm-read-limited"
#   description = "Allow EC2 to read specific SSM parameters"

#   policy = jsonencode({
#     Version = "2012-10-17",
#     Statement = [
#       {
#         Effect = "Allow",
#         Action = [
#           "ssm:GetParameter",
#           "ssm:GetParameters",
#           "ssm:GetParametersByPath"
#         ],
#         Resource : "arn:aws:ssm:${var.region}:${var.account_id}:parameter/airflow/variables/*"
#       }
#     ]
#   })
# }

# resource "aws_iam_role_policy_attachment" "ssm_read_attach" {
#   role       = aws_iam_role.ec2_instance_role.name
#   policy_arn = aws_iam_policy.ssm_read_limited.arn
# }

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
    dags_bucket      = var.dags_bucket
    rds_host         = aws_db_instance.rds_instance.address
    rds_port         = aws_db_instance.rds_instance.port
    rds_username     = var.rds_username
    rds_password     = var.rds_password
  })

  iam_instance_profile = aws_iam_instance_profile.ec2_instance_profile.name

  root_block_device {
    volume_size           = 20
    volume_type           = "gp3"
    delete_on_termination = true
  }

  tags = {
    Name = "${var.project}-airflow-instance"
  }

  depends_on = [aws_db_instance.rds_instance]
}
