terraform {
  required_providers {
    aws = {
      source = "hashicorp/aws"
    }
  }
  backend "s3" {
    bucket = "gussf-terraform-playground"
    key    = "playground.tfstate"
    region = "us-east-1"
  }
}

provider "aws" {
  profile = "default"
  region  = "us-east-1"
}


module "vpc" {
  source = "terraform-aws-modules/vpc/aws"

  name = "gussf-vpc"
  cidr = "10.0.0.0/16"

  azs             = ["us-east-1a", "us-east-1b", "us-east-1c"]
  private_subnets = ["10.0.1.0/24", "10.0.2.0/24", "10.0.3.0/24"]
  public_subnets  = ["10.0.101.0/24", "10.0.102.0/24", "10.0.103.0/24"]

  manage_default_security_group = true
  default_security_group_ingress = [
    {
      cidr_blocks = "0.0.0.0/0"
      protocol    = -1
      self        = false
      from_port   = 0
      to_port     = 0
    }
  ]
  default_security_group_egress = [
    {
      cidr_blocks = "0.0.0.0/0"
      protocol    = -1
      self        = false
      from_port   = 0
      to_port     = 0
    }
  ]

  enable_nat_gateway = true
  enable_vpn_gateway = false

  tags = {
    Terraform   = "true"
    Environment = "dev"
  }
}

module "alb" {
  source = "./alb"

  alb_name    = "${var.prefix}-alb"
  alb_tg_name = "${var.prefix}-alb-tg"

  alb_subnets   = module.vpc.public_subnets
  alb_tg_port   = 8080
  alb_tg_vpc_ip = module.vpc.vpc_id

  alb_listen_port = 80
}

module "ecs_fargate_cluster" {
  source = "./ecs-fargate"

  cluster_name = "${var.prefix}-cluster"

  task_name = "${var.prefix}-task"
  task_azs  = module.vpc.private_subnets

  container_essential = true
  container_name      = "${var.prefix}-container"
  container_image     = "gussf/teste-k8s"
  container_cpu       = 256
  container_memory    = 512
  container_port      = 8080
  host_port           = 8080

  service_name  = "${var.prefix}-service"
  desired_count = 1

  alb_target_group_arn = module.alb.target_group_arn

  ecs_security_group = module.vpc.default_security_group_id
}



# module "alb-ec2-test" {
#   source = "./alb-ec2-grpc"
#   providers = {
#     aws = aws
#   }
#   target_instance_name = "ec2-name"
#   alb_name             = "alb-name"
#   instance_name        = "ec2-name-2"
#   environment          = "dev"
# }

/* 
module "sqs-lambda-test" {
  source = "./sqs-lambda"

  sqs_name        = "test-sqs"
  lambda_filename = "./resources/lambda.zip"
  environment     = "dev"
}
 */