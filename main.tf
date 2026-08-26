terraform {
  required_version = ">= 1.13.0"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
}

provider "aws" {
  region = "ap-south-1"
}

resource "aws_security_group" "web_sg" {
  name        = "web-sg"
  description = "Security group for web server"

  ingress {
    description = "SSH from trusted IP only"

    from_port = 22
    to_port   = 22
    protocol  = "tcp"

    cidr_blocks = ["103.170.71.117/32"]
  }
}