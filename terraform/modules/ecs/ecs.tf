locals {
  task_env_vars = concat([
    {
      name  = "CODEBUILD_PROJECT_NAME"
      value = tostring(var.codebuild_project_name)
    },
    {
      name  = "SQS_URL"
      value = tostring(var.events_sqs_url)
    },
    {
      name  = "ACCOUNT_ID"
      value = tostring(var.account_id)
    },
    {
      name  = "REGION"
      value = tostring(var.region)
    }
    ], flatten([
      for env_key, env_value in var.extra_env_vars : [
        {
          name  = env_key,
          value = env_value
        }
      ]
    ])
  )
}

resource "aws_ecs_cluster" "ecs_cluster" {
  name = "${var.name}-events-cluster"
  tags = var.tags
  #  setting {
  #    name  = "containerInsights"
  #    value = "enabled"
  #  }
}

resource "aws_ecs_service" "service" {
  name = "${var.name}-cloud-connector"

  cluster = aws_ecs_cluster.ecs_cluster.id
  network_configuration {
    subnets         = var.vpc_subnets_private_ids
    security_groups = [aws_security_group.sg.id]
  }

  desired_count         = 1
  launch_type           = "FARGATE"
  task_definition       = aws_ecs_task_definition.task_definition.arn
  wait_for_steady_state = true
  tags                  = var.tags

  lifecycle {
    ignore_changes = [desired_count]
  }
}


resource "aws_ecs_task_definition" "task_definition" {
  family                   = var.name
  depends_on               = [aws_iam_role.execution]
  requires_compatibilities = ["FARGATE"]
  network_mode             = "awsvpc"
  execution_role_arn       = aws_iam_role.execution.arn
  # ARN of the task execution role that the Amazon ECS container agent and the Docker daemon can assume
  task_role_arn = local.ecs_task_role_arn
  # ARN of IAM role that allows your Amazon ECS container task to make calls to other AWS services.
  cpu    = var.ecs_task_cpu
  memory = var.ecs_task_memory

  container_definitions = jsonencode([
    {
      environment = local.task_env_vars
      name        = "CloudConnector"
      image       = var.image
      essential   = true
      # secrets = [
      #   {
      #     name      = "SECURE_API_TOKEN"
      #     valueFrom = var.secure_api_token_secret_name
      #   }
      # ]
      portMappings = [
        {
          containerPort = 5000
        }
      ]
      logConfiguration = {
        logDriver = "awslogs"
        options = {
          awslogs-group         = aws_cloudwatch_log_group.log.id
          awslogs-region        = data.aws_region.current.name
          awslogs-stream-prefix = "ecs"
        }
      }
    },
  ])
  tags = var.tags
}

data "aws_region" "current" {}

resource "aws_cloudwatch_log_group" "log" {
  name_prefix       = var.name
  retention_in_days = var.cloudwatch_log_retention
  tags              = var.tags
}

resource "aws_cloudwatch_log_stream" "stream" {
  name           = "${var.name}-alerts"
  log_group_name = aws_cloudwatch_log_group.log.name
}

