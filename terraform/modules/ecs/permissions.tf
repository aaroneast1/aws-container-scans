locals {
  ecs_task_role_id          = aws_iam_role.task.id
  ecs_task_role_arn         = aws_iam_role.task.arn
  sqs_arn                   = var.events_sqs_arn
  sqs_url                   = var.events_sqs_url
  ecs_task_role_name_suffix = var.connector_ecs_task_role_name
}

# data "aws_ssm_parameter" "sysdig_secure_api_token" {
#   name = var.secure_api_token_secret_name
# }

#---------------------------------
# task role
# - if organizational, role is inherited from root lvl, to avoid cyclic dependencies
# - otherwise is created in current account
# - duplicated in /examples/organizational/permissions.tf
#---------------------------------
# data "aws_iam_role" "task_inherited" {
#   count = var.is_organizational ? 1 : 0
#   name  = var.organizational_config.connector_ecs_task_role_name
# }

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

# resource "aws_iam_role_policy" "task_policy_s3" {
#   count  = var.is_organizational ? 0 : 1
#   name   = "${var.name}-AllowS3Read"
#   role   = local.ecs_task_role_id
#   policy = data.aws_iam_policy_document.iam_role_task_policy_s3[0].json
# }
# data "aws_iam_policy_document" "iam_role_task_policy_s3" {
#   count = var.is_organizational ? 0 : 1
#   statement {
#     effect = "Allow"
#     actions = [
#       "s3:GetObject",
#       "s3:ListBucket"
#     ]
#     resources = ["*"]
#     # resources = [var.cloudtrail_s3_arn # would need this as param]
#   }
# }

# resource "aws_iam_role_policy" "task_policy_assume_role" {
#   count  = var.is_organizational ? 1 : 0
#   name   = "${var.name}-AllowS3AssumeRole"
#   role   = local.ecs_task_role_id
#   policy = data.aws_iam_policy_document.iam_role_task_assume_role[0].json
# }

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

# image scanning - ecr
# resource "aws_iam_role_policy" "ecr_reader" {
#   count  = local.deploy_image_scanning ? 1 : 0
#   name   = "ECRReader"
#   role   = local.ecs_task_role_id
#   policy = data.aws_iam_policy_document.ecr_reader[0].json
# }

# data "aws_iam_policy_document" "ecr_reader" {
#   count = local.deploy_image_scanning ? 1 : 0
#   statement {
#     effect = "Allow"
#     actions = [
#       "ecr:GetAuthorizationToken",
#       "ecr:BatchCheckLayerAvailability",
#       "ecr:GetDownloadUrlForLayer",
#       "ecr:GetRepositoryPolicy",
#       "ecr:DescribeRepositories",
#       "ecr:ListImages",
#       "ecr:DescribeImages",
#       "ecr:BatchGetImage",
#       "ecr:GetLifecyclePolicy",
#       "ecr:GetLifecyclePolicyPreview",
#       "ecr:ListTagsForResource",
#       "ecr:DescribeImageScanFindings"
#     ]
#     resources = ["*"]
#     # resources = var.is_organizational ? ["arn:aws:ecr:*:*:repository/*", "arn:aws:ecr-public::*:repository/*", "arn:aws:ecr-public::*:registry/*"] : ["arn:aws:ecr-public::${data.aws_caller_identity.me.account_id}:repository/*", "arn:aws:ecr-public::${data.aws_caller_identity.me.account_id}:repository/*", "arn:aws:ecr-public::${data.aws_caller_identity.me.account_id}:registry/*"]
#   }
# }

#---------------------------------
# execution role
# This role is required by tasks to pull container images and publish container logs to Amazon CloudWatch on your behalf.
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


# resource "aws_iam_role_policy" "task_read_parameters" {
#   name   = "${var.name}-TaskReadParameters"
#   policy = data.aws_iam_policy_document.task_read_parameters.json
#   role   = aws_iam_role.execution.id
# }
# data "aws_iam_policy_document" "task_read_parameters" {
#   statement {
#     effect    = "Allow"
#     actions   = ["ssm:GetParameters"]
#     resources = [data.aws_ssm_parameter.sysdig_secure_api_token.arn]
#   }
# }


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
