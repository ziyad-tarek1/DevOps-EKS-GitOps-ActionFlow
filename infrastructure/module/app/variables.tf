variable "app_name" {

}

variable "namespace" {
  default = "kube-system"
}
variable "create_namespace" {

}
variable "chart" {}
variable "repository" {}
variable "chart_version" {}
variable "values_file" {}

variable "eks_dependency" {

}