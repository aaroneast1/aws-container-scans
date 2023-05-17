resource "aws_iam_role" "codebuild_role" {
  name = "${var.name}-codebuild-role"
  assume_role_policy = jsonencode(
    {
      Version = "2012-10-17",
      Statement = [
        {
          Action = "sts:AssumeRole",
          Principal = {
            Service = "codebuild.amazonaws.com"
          },
          Effect = "Allow",
          Sid = "23l4kj"
        }
      ]
    }
  )
}

resource "aws_iam_policy" "codebuild_iam_policy" {
  name = "${var.name}-codebuild-policy"
  path = "/"

  policy = jsonencode(
  {
    "Version": "2012-10-17",
    Statement = [
      {
        Action = [
          "ec2:CreateNetworkInterface",
          "ec2:DescribeDhcpOptions",
          "ec2:DescribeNetworkInterfaces",
          "ec2:DeleteNetworkInterface",
          "ec2:DescribeSubnets",
          "ec2:DescribeSecurityGroups",
          "ec2:DescribeVpcs",
          "sqs:GetQueueUrl",
          "sqs:ReceiveMessage",
          "sqs:SendMessage",
          "sqs:DeleteMessage"
        ],
        "Effect": "Allow",
        "Resource": "*"
      },
      {
        Action = [
          "s3:*",
          "secretsmanager:*"
        ],
        "Effect": "Allow",
        "Resource": "*"
      },
      {
        Action = [
          "logs:CreateLogGroup",
          "logs:CreateLogStream",
          "logs:PutLogEvents",
          "codebuild:CreateReportGroup",
          "codebuild:CreateReport",
          "codebuild:UpdateReport",
          "codebuild:BatchPutTestCases"
        ],
        "Effect": "Allow",
        "Resource": "*"
      },
      {
        Action = [
          "codestar-connections:*"
        ],
        "Effect": "Allow",
        "Resource": "arn:aws:codestar-connections:*:*:connection/*"
      }
    ]
  })
}

resource "aws_iam_policy" "codebuild_logging_policy" {
  name = "${var.name}-codebuild-logging-policy"
  path = "/"

  policy = jsonencode(
    {
      "Version": "2012-10-17",
      Statement = [
        {
          Action = [
            "logs:CreateLogGroup",
            "logs:CreateLogStream",
            "logs:PutLogEvents",
          ],
          Resource: "arn:aws:logs:*:*:log-group:*",
          Effect: "Allow"
        },
        {
          Action = [
            "codebuild:CreateReportGroup",
            "codebuild:CreateReport",
            "codebuild:UpdateReport",
            "codebuild:BatchPutTestCases"
          ],
          Resource: "arn:aws:codebuild:*:*:report-group/*",
          Effect: "Allow"
        }
      ]
    }
  )
}

resource "aws_iam_role_policy_attachment" "codebuild_logs" {
  role = aws_iam_role.codebuild_role.name
  policy_arn = aws_iam_policy.codebuild_logging_policy.arn
}

resource "aws_iam_role_policy_attachment" "codebuild_ecr" {
  role = aws_iam_role.codebuild_role.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonEC2ContainerRegistryReadOnly"
}

resource "aws_iam_role_policy_attachment" "codebuild_job" {
  role = aws_iam_role.codebuild_role.name
  policy_arn = aws_iam_policy.codebuild_iam_policy.arn
}