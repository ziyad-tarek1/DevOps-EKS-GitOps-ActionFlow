output "ecr_arn" {
  description = "ECR Repository ARN"
  value       = module.ecr_repo.ecr_repository_arn
}

output "ecr_url" {
  description = "ECR Repository URL"
  value       = module.ecr_repo.ecr_repository_url
}