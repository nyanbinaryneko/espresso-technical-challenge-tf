resource "aws_security_group" "task" {
  name        = "default-task-sg"
  description = "Allow task to run on fargate"
  vpc_id      = data.aws_vpc.default.id
}

#
# HTTP from world (for Load Balancer)
#
resource "aws_security_group" "http_world" {
  name        = "http-from-world"
  description = "Full external access to http(s)"
  vpc_id      = data.aws_vpc.default.id
}

resource "aws_security_group_rule" "http_world" {
  cidr_blocks       = ["0.0.0.0/0"]
  from_port         = 80
  protocol          = "tcp"
  security_group_id = aws_security_group.http_world.id
  to_port           = 80
  type              = "ingress"
}

resource "aws_security_group_rule" "outbound_world" {
  cidr_blocks       = ["0.0.0.0/0"]
  from_port         = 0
  protocol          = "-1"
  security_group_id = aws_security_group.http_world.id
  to_port           = 0
  type              = "egress"
}

#
# HTTP from Load Balancer (for Task)
#
resource "aws_security_group" "task_lb" {
  name        = "lb-to-task"
  description = "Allow load balancer to talk to task"
  vpc_id      = data.aws_vpc.default.id
}

resource "aws_security_group_rule" "inbound_task" {
  from_port                = 80
  protocol                 = "tcp"
  security_group_id        = aws_security_group.task.id
  source_security_group_id = aws_security_group.http_world.id
  to_port                  = 80
  type                     = "ingress"
}

resource "aws_security_group_rule" "outbound_task" {
  cidr_blocks       = ["0.0.0.0/0"]
  from_port         = 0
  protocol          = "-1"
  security_group_id = aws_security_group.task.id
  to_port           = 0
  type              = "egress"
}
