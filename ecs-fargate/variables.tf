variable "service_name" {}
variable "desired_count" {}
variable "cluster_name" {}
variable "task_name" {}
variable "task_azs" {}
variable "container_name" {}
variable "container_image" {}
variable "container_cpu" {}
variable "container_memory" {}
variable "container_port" {}
variable "host_port" {}
variable "ecs_security_group" {}
variable "alb_target_group_arn" {}
variable "container_essential" {
  default = false
}