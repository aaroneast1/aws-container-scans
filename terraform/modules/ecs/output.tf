output "ecs_service_arn" {
  description = "ECS Service ARN"
  value       = aws_ecs_service.service.arn
}

