module "eventbridge" {
  source = "terraform-aws-modules/eventbridge/aws"

  create_bus = false

  attach_sqs_policy = true
  
  sqs_target_arns = [
    aws_sqs_queue.sqs_sysdig_queue.arn,
    aws_sqs_queue.sqs_queue_deadletter.arn
  ]

  rules = {
    ecr-events = {
      description   = "Capture all created service events",
      event_pattern = jsonencode({
        "source": ["aws.ecr"],
        "detail-type": ["ECR Image Action"],
        "detail": {
          "action-type":["PUSH"],
          "result": ["SUCCESS"]
          }
      })
    }
    ecs-events = {
      description   = "Capture all created service events",
      event_pattern = jsonencode({
        "source": ["aws.ecs"],
        "detail-type": ["ECS Task State Change"]
      })
    }
  }

  targets = {
    ecr-events = [
      
      {
        name = "${var.name}-service-ecr"
        arn  = var.codebuild_project_arn
        attach_role_arn = aws_iam_role.codebuid_trigger_role.arn
      },
      {
        name            = "${var.name}-ecr-events"
        arn             = aws_sqs_queue.sqs_sysdig_queue.arn
        dead_letter_arn = aws_sqs_queue.sqs_queue_deadletter.arn
      }
    ]
    ecs-events = [
      {
        name = "${var.name}-service-ecs"
        arn  = var.codebuild_project_arn
        attach_role_arn = aws_iam_role.codebuid_trigger_role.arn
      },
      {
        name            = "${var.name}-ecs-events"
        arn             = aws_sqs_queue.sqs_sysdig_queue.arn
        dead_letter_arn = aws_sqs_queue.sqs_queue_deadletter.arn
      }
    ]
  }
}

data "aws_iam_policy_document" "assume_role" {
  statement {
    effect  = "Allow"
    actions = ["sts:AssumeRole"]

    principals {
      type        = "Service"
      identifiers = ["events.amazonaws.com"]
    }
  }
}

resource "aws_iam_role" "codebuid_trigger_role" {
  name               = "${var.name}-codebuild-trigger"
  assume_role_policy = data.aws_iam_policy_document.assume_role.json
}

data "aws_iam_policy_document" "codebuild_trigger_policy" {
  statement {
    effect    = "Allow"
    actions   = ["codebuild:StartBuild"]
    resources = [var.codebuild_project_arn]
  }
}

resource "aws_iam_role_policy" "codebuild_trigger_role_policy" {
  name   = "${var.name}-codebuild-trigger-role-policy"
  role   = aws_iam_role.codebuid_trigger_role.id
  policy = data.aws_iam_policy_document.codebuild_trigger_policy.json
}

# iam permission to allow API invocation for API destinations
# resource "aws_iam_policy" "codebuild_trigger_policy" {

#   name        = "${var.name}-codebuild-trigger-policy"
#   path        = "/"
#   description = "Allows trigger of a codebuild job"

#   policy = jsonencode({
#     Version = "2012-10-17"
#     Statement = [
#       {
#         Action = [
#           "codebuild:StartBuild"
#         ]
#         Effect = "Allow"
#         Resource = [
#           module.codebuild[0].project_arn
#         ]
#       },
#     ]
#   })
# }

# create the IAM role
# resource "aws_iam_role" "codebuild_trigger_role" {
#   name               = "${var.name}-codebuild-trigger-role"
#   assume_role_policy = data.aws_iam_policy_document.assume_role.json
# }

# attach the invoke api policy
# resource "aws_iam_role_policy_attachment" "invoke_api" {
#   role       = aws_iam_role.codebuild_trigger_role.id
#   policy_arn = aws_iam_policy.codebuild_trigger_policy.arn
# }