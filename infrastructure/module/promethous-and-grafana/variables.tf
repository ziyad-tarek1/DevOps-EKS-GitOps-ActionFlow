
variable "namespace" {
  description = "The namespace in which to deploy Prometheus"
  type        = string
  default     = "prometheus"

}

variable "chart_version" {
  description = "The version of the Prometheus Helm chart to deploy"
  type        = string
  default     = "45.7.1"

}

variable "values_file" {
  description = "The file path to the custom Prometheus Helm values file"
  type        = string
}

variable "eks_dependency" {
  description = "EKS dependency to ensure Prometheus deploys only after the cluster is ready"
}
