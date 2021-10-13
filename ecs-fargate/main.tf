data "aws_iam_role" "ecs_task_execution_role" {
  name = "ecsTaskExecutionRole"
}


#################################################
# ECS CLUSTER
#################################################
resource "aws_ecs_cluster" "cluster" {
  name = var.cluster_name

  setting {
    name  = "containerInsights"
    value = "enabled"
  }
}

#################################################
# ECS TASK DEFINITION
#################################################
resource "aws_ecs_task_definition" "task" {
  family = var.task_name
  requires_compatibilities = [ "FARGATE" ]
  network_mode = "awsvpc"
  cpu = var.container_cpu
  memory = var.container_memory
  execution_role_arn = data.aws_iam_role.ecs_task_execution_role.arn
  container_definitions = jsonencode([
    {
      name      = var.container_name
      image     = var.container_image
      essential = var.container_essential
      portMappings = [
        {
          containerPort = var.container_port
          hostPort      = var.host_port
        }
      ]
      logConfiguration = {
          logDriver = "awslogs",
          options = {
              awslogs-group = "/aws/ecs/awslogs-test"
              awslogs-region = "us-east-1"
              awslogs-stream-prefix = "awslogs-example"
          }
      }
    }
  ])
}

#################################################
# ECS SERVICE
#################################################

resource "aws_ecs_service" "service" {
  name            = var.service_name
  cluster         = aws_ecs_cluster.cluster.id
  task_definition = aws_ecs_task_definition.task.arn
  desired_count   = var.desired_count
  launch_type     = "FARGATE"
  network_configuration {
    subnets = var.task_azs
    security_groups = [ var.ecs_security_group ]
  }

  load_balancer {
    target_group_arn = var.alb_target_group_arn
    container_name = var.container_name
    container_port = var.container_port
  }
  
}

