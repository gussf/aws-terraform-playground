terraform {
  required_providers {
    aws = {
      source = "hashicorp/aws"
    }
  }
}


data "aws_vpc" "main" {
  filter {
    name   = "tag:Name"
    values = ["default"]
  }
}


resource "aws_security_group" "allow_ssh" {
  name        = "allow_ssh"
  description = "Allow SSH inbound traffic"
  vpc_id      = data.aws_vpc.main.id

  ingress {
    description = "SSH from all"
    from_port   = 22
    to_port     = 22
    protocol    = "TCP"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port        = 0
    to_port          = 0
    protocol         = "-1"
    cidr_blocks      = ["0.0.0.0/0"]
    ipv6_cidr_blocks = ["::/0"]
  }

  tags = {
    Name = "ALLOW_SSH"
  }
}


data "aws_ami" "ubuntu" {
  most_recent = true

  filter {
    name   = "name"
    values = ["ubuntu/images/hvm-ssd/ubuntu-focal-20.04-amd64-server-*"]
  }

  owners = ["099720109477"]
}

resource "aws_instance" "ec2_source" {
  ami             = data.aws_ami.ubuntu.id
  instance_type   = "t2.micro"
  key_name        = "my-key-pair"
  security_groups = [aws_security_group.allow_ssh.name]
  tags = {
    Name        = var.instance_name
    Environment = var.environment
  }
}


resource "aws_instance" "ec2_target" {
  ami             = data.aws_ami.ubuntu.id
  instance_type   = "t2.micro"
  key_name        = "my-key-pair"
  security_groups = [aws_security_group.allow_ssh.name]
  tags = {
    Name        = var.target_instance_name
    Environment = var.environment
  }

}


data "aws_subnet_ids" "selected" {
  vpc_id = data.aws_vpc.main.id
  tags = {
    Name = "default*"
  }
}



# ALB

resource "aws_alb_target_group" "test" {
  name     = "example-tg"
  port     = 80
  protocol = "HTTP"
  vpc_id   = data.aws_vpc.main.id
}


resource "aws_alb" "alb" {
  name                       = var.alb_name
  internal                   = false
  load_balancer_type         = "application"
  security_groups            = [aws_security_group.allow_ssh.id]
  subnets                    = data.aws_subnet_ids.selected.ids
  enable_deletion_protection = false
  enable_http2               = true
  tags = {
    Environment = var.environment
  }
}

resource "aws_alb_listener" "listener_http" {
  load_balancer_arn = aws_alb.alb.arn
  port              = "80"
  protocol          = "HTTP"

  default_action {
    target_group_arn = aws_alb_target_group.test.arn
    type             = "forward"
  }
}

resource "aws_alb_target_group_attachment" "register_targets" {
  target_group_arn = aws_alb_target_group.test.arn
  target_id        = aws_instance.ec2_target.id
  port             = 80
}


