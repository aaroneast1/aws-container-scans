output "sqs_arn" {
  description = "SQS arn"
  value       = aws_sqs_queue.sqs_sysdig_queue.arn
}
output "sqs_url" {
  description = "SQS url"
  value       = aws_sqs_queue.sqs_sysdig_queue.id
}
output "sqs_deadletter_arn" {
  description = "SQS deadletter arn"
  value       = aws_sqs_queue.sqs_queue_deadletter.arn
}
output "sqs_deadletter_url" {
  description = "SQS deadletter url"
  value       = aws_sqs_queue.sqs_queue_deadletter.id
}
