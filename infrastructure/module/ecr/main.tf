resource "aws_ecr_repository" "ecr_repo" {
  name = var.ecr_name
  image_scanning_configuration {
    scan_on_push = var.scan_on_push
  }
}