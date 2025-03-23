variable "ecr_name" {
  description = "Name of the ECR repository"
  type        = string
}

variable "scan_on_push" {
  description = "Whether to scan images on push"
  type        = bool
  default     = true
}