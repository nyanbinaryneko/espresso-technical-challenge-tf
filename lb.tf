# Create load balancer
resource "aws_lb" "task" {
  name               = "task-ecs-test"
  load_balancer_type = "application"
  security_groups    = [aws_security_group.http_world.id]
  subnets            = data.aws_subnets.default.ids
}

# Create target group to connect services to
resource "aws_lb_target_group" "task" {
  name                 = "task"
  deregistration_delay = 30
  port                 = 80
  protocol             = "HTTP"
  target_type          = "ip"
  vpc_id               = data.aws_vpc.default.id
}

# Create listener for HTTP
resource "aws_lb_listener" "task" {
  load_balancer_arn = aws_lb.task.id
  port              = 80
  protocol          = "HTTP"
  default_action {
    target_group_arn = aws_lb_target_group.task.id
    type             = "forward"
  }
}