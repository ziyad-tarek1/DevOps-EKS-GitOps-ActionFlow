output "iam_role_arn" {
  value = aws_iam_role.cluster_autoscaler.arn
}

output "helm_release_name" {
  value = helm_release.cluster_autoscaler.name
}
