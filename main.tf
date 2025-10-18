terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
}

provider "aws" {
  region = "eu-north-1"
}

resource "aws_vpc" "main" {
  cidr_block = var.vpc_cidr

  tags = {
    Name = "main"
  }
}

resource "aws_bucket" "dags_bucket" {
  bucket = var.dags_bucket

  tags = {
    Name = "${var.project}-dags-bucket"
  }
}
