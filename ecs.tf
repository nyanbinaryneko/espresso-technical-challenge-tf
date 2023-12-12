resource "aws_ecs_task_definition" "hello_world" {
  family                   = "service"
  memory                   = 512
  cpu                      = 256
  network_mode             = "awsvpc"
  requires_compatibilities = ["FARGATE"]
  execution_role_arn       = aws_iam_role.hello_world_ecs_exec_role.arn
  # made package visibility public for the duration of the challenge
  container_definitions = jsonencode([
    {
      name      = "hello-world"
      essential = true
      image     = "ghcr.io/nyanbinaryneko/espesso-technical-challenge:latest"
      portMappings = [
        {
          protocol      = "tcp"
          containerPort = 80
          hostPort      = 80
        }
      ]
      logConfiguration = {
        logDriver = "awslogs",
        options = {
          awslogs-group         = aws_cloudwatch_log_group.hello_world_service_logs.name,
          awslogs-region        = data.aws_region.current.name,
          awslogs-stream-prefix = "ecs"
        }
      }
    }
  ])
  #<<DEFINITION
  # [
  #   {
  #     "name": "hello-world",
  #     "image": 
  #     "cpu": 256,
  #     "memory": 512,
  #     "essential": true,
  #     "logConfiguration": {
  #       "logDriver": "awslogs",
  #       "options": {
  #         "awslogs-group": "${}",
  #         "awslogs-region": "${data.aws_region.current.name}",
  #         "awslogs-stream-prefix": "ecs"
  #       }
  #     }
  #   }
  # ]
  # DEFINITION
}

resource "aws_kms_key" "hello_world_kms" {
  description             = "hello world rust kms key"
  deletion_window_in_days = 7
}

resource "aws_cloudwatch_log_group" "hello_world_service_logs" {
  name = "hello_world"
}

resource "aws_ecs_cluster" "hello_world_cluster" {
  name = "hello_world"

  configuration {
    execute_command_configuration {
      kms_key_id = aws_kms_key.hello_world_kms.arn
      logging    = "OVERRIDE"

      log_configuration {
        cloud_watch_encryption_enabled = true
        cloud_watch_log_group_name     = aws_cloudwatch_log_group.hello_world_service_logs.name
      }
    }
  }
}

resource "aws_ecs_cluster_capacity_providers" "default" {
  cluster_name = aws_ecs_cluster.hello_world_cluster.name

  capacity_providers = ["FARGATE"]

  default_capacity_provider_strategy {
    base              = 1
    weight            = 100
    capacity_provider = "FARGATE"
  }
}


resource "aws_ecs_service" "hello_world_service" {
  name            = "hello_world"
  task_definition = aws_ecs_task_definition.hello_world.arn
  desired_count   = 1
  cluster         = aws_ecs_cluster.hello_world_cluster.id
  network_configuration {
    security_groups = [aws_security_group.task.id]
    subnets         = data.aws_subnets.default.ids
    # assign public ip so it can get the image
    assign_public_ip = true
  }
 load_balancer {
    container_name   = "hello-world"
    container_port   = 80
    target_group_arn = aws_lb_target_group.task.arn
  }
  health_check_grace_period_seconds = 2147483647
  }