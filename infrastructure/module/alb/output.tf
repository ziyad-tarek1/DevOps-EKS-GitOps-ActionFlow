
output "iam_role_arn" {
  value = aws_iam_role.aws_lbc.arn
}

output "helm_release_name" {
  value = helm_release.aws_lbc.name

}