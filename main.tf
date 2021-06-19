terraform {
  required_providers {
    aws = {
      source = "hashicorp/aws"
    }
  }
}

provider "aws" {
  profile = "default"
  region  = "us-east-1"
}

data "aws_ami" "ubuntu" {
  most_recent = true

  filter {
    name   = "name"
    values = ["ubuntu/images/hvm-ssd/ubuntu-focal-20.04-amd64-server-*"]
  }

  owners = ["099720109477"]
}

resource "aws_instance" "ec2_gustavo" {
  ami           = data.aws_ami.ubuntu.id
  instance_type = "t2.micro"
  key_name = "my-key-pair"
  tags = {
    Name        = var.instance_name
    Environment = var.environment
  }
}
