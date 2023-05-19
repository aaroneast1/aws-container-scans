output "vpc_id" {
  description = "VPC ID"
  value       = module.vpc.vpc_id
}
output "azs" {
  description = "availability zones"
  value       = var.vpc_azs
}
output "private_subnets" {
  description = "private subnet ips"
  value       = var.vpc_private_subnets
}
output "public_subnets" {
  description = "public subnet ips"
  value       = var.vpc_public_subnets
}
output "private_subnets_ids" {
  description = "private subnet ids"
  value       = module.vpc.private_subnets
}
