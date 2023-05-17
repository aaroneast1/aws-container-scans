output "project_arn" {
  description = "Code Build project arn"
  value       = aws_codebuild_project.codebuild_job.arn
}

output "project_name" {
  description = "Code Build project name"
  value       = aws_codebuild_project.codebuild_job.name
}
