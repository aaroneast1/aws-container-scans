locals {
  sqs_arn = aws_sqs_queue.sqs_sysdig_queue.arn
  sqs_dead_letter_arn = aws_sqs_queue.sqs_queue_deadletter.arn
  sqs_url = aws_sqs_queue.sqs_sysdig_queue.id
}

resource "aws_sqs_queue" "sqs_sysdig_queue" {
  name = "${var.name}-service-events"
  delay_seconds             = 1
  max_message_size          = 2048
  message_retention_seconds = 86400 # keep 24hrs

  # redrive_policy = jsonencode({
  #   deadLetterTargetArn = aws_sqs_queue.sqs_queue_deadletter.arn
  #   maxReceiveCount     = 4
  # })

  tags = var.tags
}

resource "aws_sqs_queue" "sqs_queue_deadletter" {
  name = "${var.name}-deadletter-queue"
}

resource "aws_sqs_queue_policy" "queue" {
  queue_url = aws_sqs_queue.sqs_sysdig_queue.id
  policy    = data.aws_iam_policy_document.queue.json
}

data "aws_iam_policy_document" "queue" {
  statement {
    sid     = "${var.name}-events-policy"
    actions = ["sqs:SendMessage"]

    principals {
      type        = "Service"
      identifiers = ["events.amazonaws.com"]
    }

    resources = [
      aws_sqs_queue.sqs_sysdig_queue.arn,
      aws_sqs_queue.sqs_queue_deadletter.arn
    ]
  }
}
