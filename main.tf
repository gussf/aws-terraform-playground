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

module "alb-ec2-test" {
  source = "./alb-ec2-grpc"
  providers = {
    aws = aws
  }
  target_instance_name = "ec2-name"
  alb_name             = "alb-name"
  instance_name        = "ec2-name-2"
  environment          = "dev"
}

/* 
module "sqs-lambda-test" {
  source = "./sqs-lambda"

  sqs_name        = "test-sqs"
  lambda_filename = "./resources/lambda.zip"
  environment     = "dev"
}
 */