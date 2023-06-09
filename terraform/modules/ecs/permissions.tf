locals {
  ecs_task_role_id          = aws_iam_role.task.id
  ecs_task_role_arn         = aws_iam_role.task.arn
  sqs_arn                   = var.events_sqs_arn
  sqs_url                   = var.events_sqs_url
  ecs_task_role_name_suffix = var.connector_ecs_task_role_name
}


#---------------------------------
# task role
#---------------------------------

resource "aws_iam_role" "task" {
  # count              = var.is_organizational ? 0 : 1
  name               = "${var.name}-${local.ecs_task_role_name_suffix}"
  assume_role_policy = data.aws_iam_policy_document.task_assume_role.json
  path               = "/"
  tags               = var.tags
}

data "aws_iam_policy_document" "task_assume_role" {
  # count = var.is_organizational ? 0 : 1
  statement {
    effect = "Allow"
    principals {
      identifiers = ["ecs-tasks.amazonaws.com"]
      type        = "Service"
    }
    actions = ["sts:AssumeRole"]
  }
}

resource "aws_iam_role_policy" "task_policy_sqs" {
  name   = "${var.name}-AllowSQSUsage"
  role   = local.ecs_task_role_id
  policy = data.aws_iam_policy_document.iam_role_task_policy_sqs.json
}
data "aws_iam_policy_document" "iam_role_task_policy_sqs" {
  statement {
    effect = "Allow"
    actions = [
      "sqs:DeleteMessage",
      "sqs:ReceiveMessage"
    ]
    resources = [
      local.sqs_arn
    ]
  }
}

data "aws_iam_policy_document" "iam_role_task_assume_role" {
  # count = var.is_organizational ? 1 : 0
  statement {
    effect = "Allow"
    actions = [
      "sts:AssumeRole"
    ]
    resources = [local.ecs_task_role_arn]
  }
}

#
# scan images
#
resource "aws_iam_role_policy" "trigger_scan" {
  name   = "${var.name}-TriggerScan"
  role   = local.ecs_task_role_id
  policy = data.aws_iam_policy_document.trigger_scan.json
}
data "aws_iam_policy_document" "trigger_scan" {
  statement {
    effect = "Allow"
    actions = [
      "codebuild:StartBuild"
    ]
    resources = [var.codebuild_project_arn]
  }
}

# image scanning - ecs
resource "aws_iam_role_policy" "task_definition_reader" {
  name   = "TaskDefinitionReader"
  role   = local.ecs_task_role_id
  policy = data.aws_iam_policy_document.task_definition_reader.json
}
data "aws_iam_policy_document" "task_definition_reader" {
  statement {
    effect = "Allow"
    actions = [
      "ecs:DescribeTaskDefinition"
    ]
    resources = ["*"]
    #    resources = var.is_organizational?["arn:aws:ecs:*:*:cluster/*"]:["arn:aws:ecs:*:${data.aws_caller_identity.me.account_id}:cluster/${var.ecs_cluster_name}"]
  }
}

# Pull image cloudconnector from ECR
resource "aws_iam_role_policy" "ecr_reader" {
  name   = "ECRReader"
  role    = aws_iam_role.execution.id
  policy = data.aws_iam_policy_document.ecr_reader.json
}

data "aws_iam_policy_document" "ecr_reader" {
  statement {
    effect = "Allow"
    actions = [
      "ecr:*"
    ]
    resources = ["*"]
  }
}

#---------------------------------
# execution role
# This role is required by tasks
#---------------------------------
resource "aws_iam_role" "execution" {
  name               = "${var.name}-ECSTaskExecutionRole"
  assume_role_policy = data.aws_iam_policy_document.execution_assume_role.json
  path               = "/"
  tags               = var.tags
}
data "aws_iam_policy_document" "execution_assume_role" {
  statement {
    effect = "Allow"
    principals {
      identifiers = ["ecs-tasks.amazonaws.com"]
      type        = "Service"
    }
    actions = ["sts:AssumeRole"]
  }
}

resource "aws_iam_role_policy" "execution" {
  name   = "${var.name}-ExecutionRolePolicy"
  policy = data.aws_iam_policy_document.execution.json
  role   = aws_iam_role.execution.id
}
data "aws_iam_policy_document" "execution" {
  statement {
    effect = "Allow"
    actions = [
      "logs:CreateLogStream",
      "logs:PutLogEvents"
    ]
    resources = ["*"]
  }
}
