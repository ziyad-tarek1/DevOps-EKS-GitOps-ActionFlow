
output "eks_cluster_name" {
  description = "The name of the EKS cluster."
  value       = aws_eks_cluster.eks.name
}

output "eks_cluster_arn" {
  description = "The ARN of the EKS cluster."
  value       = aws_eks_cluster.eks.arn
}

output "worker_role_arn" {
  description = "The ARN of the worker IAM role."
  value       = aws_iam_role.worker.arn
}

output "node_group_name" {
  description = "The name of the EKS node group."
  value       = aws_eks_node_group.general.node_group_name
}

output "eks_node_group_dependency" {
  value = aws_eks_node_group.general

}

output "pod_identity_addon_status" {
  description = "The status of the EKS Pod Identity Add-On."
  value       = aws_eks_addon.pod-addon.id
}




output "eks_cluster_endpoint" {
  description = "The endpoint of the EKS cluster."
  value       = data.aws_eks_cluster.eks.endpoint
}

output "eks_cluster_ca" {
  description = "The certificate authority data of the EKS cluster."
  value       = data.aws_eks_cluster.eks.certificate_authority[0].data
}

output "eks_cluster_auth_token" {
  description = "The authentication token for the EKS cluster."
  value       = data.aws_eks_cluster_auth.eks.token
}

# output "aws_eks_addon_efs_csi_driver" {
#   value = aws_eks_addon.efs_csi_driver

# }

# output "aws_eks_addon_ebs_csi_driver" {
#   value = aws_eks_addon.ebs_csi_driver

# }

output "eks_nodes_sg" {
  value = aws_security_group.eks_nodes_sg.id
}

output "eks_control_plane_sg" {
  value = aws_security_group.eks_control_plane_sg.id
}


# output "myapp_secrets_role_arn" {
#   value = aws_iam_role.myapp_secrets.arn
# }
