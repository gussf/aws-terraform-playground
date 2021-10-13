resource "aws_alb" "alb" {
  name               = var.alb_name
  internal           = false
  load_balancer_type = "application"
  subnets            = var.alb_subnets
}

resource "aws_alb_target_group" "target_group" {
  name        = var.alb_tg_name
  port        = var.alb_tg_port
  protocol    = "HTTP"
  vpc_id      = var.alb_tg_vpc_ip
  target_type = "ip"
  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_alb_listener" "listener_http" {
  load_balancer_arn = aws_alb.alb.arn
  port              = var.alb_listen_port
  protocol          = "HTTP"

  default_action {
    target_group_arn = aws_alb_target_group.target_group.arn
    type             = "forward"
  }
}
