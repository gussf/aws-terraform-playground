variable "sqs_name" {
  description = "Value of the name for the SQS queue"
  type        = string

  validation {
    condition     = length(var.sqs_name) <= 16
    error_message = "The sqs name length must not be greater than 16 characters."
  }
}

variable "lambda_filename" {
  description = "Value of the lambda filename"
  type        = string
}


variable "environment" {
  description = "Value of the Enviroment tag for the EC2 instance (dev, hom, prd)"
  type        = string

  validation {
    condition     = contains(["dev", "hom", "prd"], var.environment)
    error_message = "The environment must be one of the following: [dev hom prd]."
  }
}

