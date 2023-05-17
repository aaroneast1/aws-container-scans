resource "aws_codebuild_project" "codebuild_job" {
  name = "${var.name}-sysdig-job"
  service_role = aws_iam_role.codebuild_role.arn

  environment {
    compute_type = "BUILD_GENERAL1_SMALL"
    image = "aws/codebuild/amazonlinux2-x86_64-standard:4.0"
    type = "LINUX_CONTAINER"
    privileged_mode = true

    environment_variable {
      name = "JOB_NAME"
      value = "${var.name}"
    }
    
    environment_variable {
      name = "RULE_NAME_MATCHER"
      value = "events-rule"
    }

    environment_variable {
      name = "SQS_QUEUE_NAME"
      value = "${var.name}-service-events"
    }

    dynamic "environment_variable" {
      for_each = var.codebuild_environment_variables
      content {
        name = environment_variable.value.name
        value = environment_variable.value.value
      }
    }
  }
  
  source {
    type = "NO_SOURCE"
    buildspec = data.local_file.buildspec.content
  }

  artifacts {
    type = "NO_ARTIFACTS"
  }

  logs_config {
    cloudwatch_logs {
      status = "ENABLED"
    }
  }
}

data "local_file" "buildspec" {
  filename = "${path.module}/buildspec.yaml"
}