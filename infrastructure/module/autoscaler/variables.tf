
variable "cluster_name" {}
variable "region" {}
variable "namespace" {
  default = "kube-system"
}
variable "service_account_name" {
  default = "cluster-autoscaler"
}
variable "policy_file_path" {}
variable "assume_role_policy_file_path" {}
