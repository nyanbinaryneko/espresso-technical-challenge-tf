# Basic policy to allow tasks to create and push logging event
resource "aws_iam_policy" "hello_world_ecs_exec_policy" {
  name = "hello_world_ecs_exec"

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = [
          "logs:CreateLogStream",
          "logs:PutLogEvents",
          "kms:Decrypt",
          "kms:Encrypt",
          "kms:GenerateDataKey"
        ]
        Effect   = "Allow"
        Resource = "*"
      },
    ]
  })
}


# Attach the policy to a role that ecs can assume
resource "aws_iam_role" "hello_world_ecs_exec_role" {
  name = "hello-world-task"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Sid    = ""
        Principal = {
          Service = "ecs-tasks.amazonaws.com"
        }
      },
    ]
  })
  managed_policy_arns = [aws_iam_policy.hello_world_ecs_exec_policy.arn]
}