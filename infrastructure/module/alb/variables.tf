
variable "cluster_name" {}
variable "vpc_id" {

}
variable "region" {}


variable "namespace" {
  default = "kube-system"
}
variable "service_account_name" {
  default = "aws-load-balancer-controller"
}

variable "chart" {}
variable "repository" {}
variable "chart_version" {}

variable "policy_file_path" {}
variable "assume_role_policy_file_path" {}

variable "eks_dependency" {

}