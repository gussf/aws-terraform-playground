variable "instance_name" {
  description = "Value of the Name tag for the EC2 instance"
  type        = string

  validation {
    condition     = length(var.instance_name) <= 16
    error_message = "The instance name length must not be greater than 16 characters."
  }
}


variable "environment" {
  description = "Value of the Enviroment tag for the EC2 instance (dev, hom, prd)"
  type        = string

  validation {
    condition     = contains(["dev", "hom", "prd"], var.environment)
    error_message = "The environment must be one of the following: [dev hom prd]."
  }
}

