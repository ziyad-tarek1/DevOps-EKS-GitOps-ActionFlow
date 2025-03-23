
/// EKS IAM Role for Cluster
resource "aws_iam_role" "eks" {
  name               = "${var.project_name}-eks-cluster"
  assume_role_policy = file("${path.module}/policies/eks-policy.json")
}

resource "aws_iam_role_policy_attachment" "eks" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSClusterPolicy"
  role       = aws_iam_role.eks.name
}

/// EKS Cluster
resource "aws_eks_cluster" "eks" {
  name     = var.eks_name
  role_arn = aws_iam_role.eks.arn
  version  = var.eks_version

  vpc_config {
    endpoint_private_access = var.endpoint_private_access
    endpoint_public_access  = var.endpoint_public_access
    subnet_ids              = var.private_subnets
    security_group_ids      = [aws_security_group.eks_control_plane_sg.id]

  }

  access_config {
    authentication_mode                         = "API"
    bootstrap_cluster_creator_admin_permissions = true
  }

  depends_on = [aws_iam_role_policy_attachment.eks]
}

/// Worker IAM Role
resource "aws_iam_role" "worker" {
  name               = "${var.project_name}-eks-worker"
  assume_role_policy = file("${path.module}/policies/ec2-policy.json")
}

/// Autoscaler IAM Policy
resource "aws_iam_policy" "autoscaler" {
  name   = "${var.project_name}-autoscaler-policy"
  policy = file("${path.module}/policies/autoscaler-policy.json")
}

/// Attach Policies to Worker Role
resource "aws_iam_role_policy_attachment" "autoscaler" {
  policy_arn = aws_iam_policy.autoscaler.arn
  role       = aws_iam_role.worker.name
}

resource "aws_iam_role_policy_attachment" "AmazonEKSWorkerNodePolicy" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSWorkerNodePolicy"
  role       = aws_iam_role.worker.name
}

resource "aws_iam_role_policy_attachment" "AmazonEKS_CNI_Policy" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKS_CNI_Policy"
  role       = aws_iam_role.worker.name
}

resource "aws_iam_role_policy_attachment" "AmazonSSMManagedInstanceCore" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonSSMManagedInstanceCore"
  role       = aws_iam_role.worker.name
}

resource "aws_iam_role_policy_attachment" "AmazonEC2ContainerRegistryReadOnly" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEC2ContainerRegistryReadOnly"
  role       = aws_iam_role.worker.name
}

/// EKS Node Group
resource "aws_eks_node_group" "general" {
  cluster_name    = aws_eks_cluster.eks.name
  version         = var.eks_version
  node_group_name = "${var.eks_name}-general"

  subnet_ids     = var.public_subnets
  capacity_type  = "ON_DEMAND"
  instance_types = var.instance_types

  scaling_config {
    desired_size = var.desired_size
    max_size     = var.max_size
    min_size     = var.min_size
  }

  update_config {
    max_unavailable = 1
  }

  labels = {
    role = "${var.eks_name}-general"
  }

  depends_on = [
    aws_iam_role_policy_attachment.AmazonEC2ContainerRegistryReadOnly,
    aws_iam_role_policy_attachment.AmazonEKS_CNI_Policy,
    aws_iam_role_policy_attachment.AmazonEKSWorkerNodePolicy
  ]

  lifecycle {
    ignore_changes = [scaling_config[0].desired_size]
  }

  node_role_arn = aws_iam_role.worker.arn
}

/// EKS Add-On for Pod Identity Agent
resource "aws_eks_addon" "pod-addon" {
  cluster_name  = aws_eks_cluster.eks.name
  addon_name    = "eks-pod-identity-agent"
  addon_version = "v1.3.4-eksbuild.1"
}


////////
/// Security Group for EKS Control Plane
resource "aws_security_group" "eks_control_plane_sg" {
  name        = "${var.project_name}-eks-control-plane-sg"
  description = "Security Group for EKS Control Plane"
  vpc_id      = var.vpc_id

  # Open ingress for testing purposes (to be removed in production)
  ingress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  # Allow all egress
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "${var.project_name}-eks-control-plane-sg"
  }
}

/// Security Group for EKS Nodes
resource "aws_security_group" "eks_nodes_sg" {
  name        = "${var.project_name}-eks-nodes-sg"
  description = "Security Group for EKS Worker Nodes"
  vpc_id      = var.vpc_id

  # Open ingress for testing purposes (to be removed in production)
  ingress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  # Allow all egress
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "${var.project_name}-eks-nodes-sg"
  }
}

//////////////////

# Fetch the EKS cluster details
data "aws_eks_cluster" "eks" {
  name = aws_eks_cluster.eks.name
}


# Fetch the authentication token for the EKS cluster
data "aws_eks_cluster_auth" "eks" {
  name = aws_eks_cluster.eks.name
}

# ///////

# data "aws_iam_policy_document" "ebs_csi_driver" {
#   statement {
#     effect = "Allow"

#     principals {
#       type        = "Service"
#       identifiers = ["pods.eks.amazonaws.com"]
#     }

#     actions = [
#       "sts:AssumeRole",
#       "sts:TagSession"
#     ]
#   }
# }


# resource "aws_iam_role" "ebs_csi_driver" {
#   name               = "${aws_eks_cluster.eks.name}-ebs-csi-driver"
#   assume_role_policy = data.aws_iam_policy_document.ebs_csi_driver.json
# }

# resource "aws_iam_role_policy_attachment" "ebs_csi_driver" {
#   policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonEBSCSIDriverPolicy"
#   role       = aws_iam_role.ebs_csi_driver.name
# }

# # Optional: only if you want to encrypt the EBS drives
# resource "aws_iam_policy" "ebs_csi_driver_encryption" {
#   name = "${aws_eks_cluster.eks.name}-ebs-csi-driver-encryption"
#   policy = jsonencode({
#     Version = "2012-10-17"
#     Statement = [
#       {
#         Effect = "Allow"
#         Action = [
#           "kms:Decrypt",
#           "kms:GenerateDataKeyWithoutPlaintext",
#           "kms:CreateGrant"
#         ]
#         Resource = "*" # Specify the resource ARN if needed
#       }
#     ]
#   })
# }

# # Optional: only if you want to encrypt the EBS drives
# resource "aws_iam_role_policy_attachment" "ebs_csi_driver_encryption" {
#   policy_arn = aws_iam_policy.ebs_csi_driver_encryption.arn
#   role       = aws_iam_role.ebs_csi_driver.name
# }

# resource "aws_eks_pod_identity_association" "ebs_csi_driver" {
#   cluster_name    = aws_eks_cluster.eks.name
#   namespace       = "kube-system"
#   service_account = "ebs-csi-controller-sa"
#   role_arn        = aws_iam_role.ebs_csi_driver.arn
# }

# resource "aws_eks_addon" "ebs_csi_driver" {
#   cluster_name             = aws_eks_cluster.eks.name
#   addon_name               = "aws-ebs-csi-driver"
#   addon_version            = "v1.38.1-eksbuild.1" //v1.35.0-eksbuild.1
#   service_account_role_arn = aws_iam_role.ebs_csi_driver.arn
# }

# /////



# # IAM Policy for EFS CSI Driver
# data "aws_iam_policy_document" "efs_csi_driver" {
#   statement {
#     effect = "Allow"

#     principals {
#       type        = "Service"
#       identifiers = ["eks.amazonaws.com"]
#     }

#     actions = [
#       "sts:AssumeRole"
#     ]
#   }
# }

# resource "aws_iam_role" "efs_csi_driver" {
#   name               = "${aws_eks_cluster.eks.name}-efs-csi-driver"
#   assume_role_policy = data.aws_iam_policy_document.efs_csi_driver.json
# }

# resource "aws_iam_role_policy_attachment" "efs_csi_driver" {
#   policy_arn = "arn:aws:iam::aws:policy/AmazonElasticFileSystemFullAccess"
#   role       = aws_iam_role.efs_csi_driver.name
# }
# resource "aws_iam_role_policy_attachment" "efs_csi_drivercsi" {
#   policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonEFSCSIDriverPolicy"
#   role       = aws_iam_role.efs_csi_driver.name
# }

# # EFS CSI Driver Addon
# resource "aws_eks_addon" "efs_csi_driver" {
#   cluster_name             = aws_eks_cluster.eks.name
#   addon_name               = "aws-efs-csi-driver"
#   addon_version            = "v2.1.4-eksbuild.1" # Replace with the latest version
#   service_account_role_arn = aws_iam_role.efs_csi_driver.arn
# }

# # Kubernetes Service Account for EFS CSI Driver
# resource "kubernetes_service_account" "efs_csi_driver" {
#   metadata {
#     name      = "efs-csi-controller-sa"
#     namespace = "kube-system"
#   }
# }


# //////////////////

# resource "helm_release" "secrets_csi_driver" {
#   name       = "secrets-store-csi-driver"
#   repository = "https://kubernetes-sigs.github.io/secrets-store-csi-driver/charts"
#   chart      = "secrets-store-csi-driver"
#   namespace  = "kube-system"
#   version    = "1.4.3"

#   // To Craete RBAC policy to use ENV variables 
#   set {
#     name  = "syncSecret.enabled"
#     value = true
#   }

#   depends_on = [aws_eks_addon.ebs_csi_driver, aws_eks_addon.efs_csi_driver]

# }


# resource "helm_release" "secrets_csi_driver_aws_provider" {
#   name       = "secrets-store-csi-driver-provider-aws"
#   repository = "https://aws.github.io/secrets-store-csi-driver-provider-aws"
#   chart      = "secrets-store-csi-driver-provider-aws"
#   namespace  = "kube-system"
#   version    = "0.3.8"
#   depends_on = [helm_release.secrets_csi_driver]

# }


# data "tls_certificate" "eks" {
#   url = aws_eks_cluster.eks.identity[0].oidc[0].issuer

# }

# resource "aws_iam_openid_connect_provider" "eks" {
#   client_id_list  = ["sts.amazonaws.com"]
#   thumbprint_list = [data.tls_certificate.eks.certificates[0].sha1_fingerprint]
#   url             = data.aws_eks_cluster.eks.identity[0].oidc[0].issuer
# }




# data "aws_iam_policy_document" "myapp_secrets" {
#   statement {
#     actions = ["sts:AssumeRoleWithWebIdentity"]
#     effect  = "Allow"
#     condition {
#       test     = "StringEquals"
#       variable = "${replace(aws_iam_openid_connect_provider.eks.url, "https://", "")}:sub"
#       values   = ["system:serviceaccount:default:myapp"] /// "system:serviceaccount:namespace:service-account-name"
#     }
#     condition {
#       test     = "StringEquals"
#       variable = "${replace(aws_iam_openid_connect_provider.eks.url, "https://", "")}:aud"
#       values   = ["sts.amazonaws.com"]
#     }
#     principals {
#       identifiers = [aws_iam_openid_connect_provider.eks.arn]
#       type        = "Federated"
#     }
#   }
# }

# resource "aws_iam_role" "myapp_secrets" {

#   name               = "${aws_eks_cluster.eks.name}-myapp-secrets"
#   assume_role_policy = data.aws_iam_policy_document.myapp_secrets.json


# }

# resource "aws_iam_policy" "myapp_secrets" {

#   name = "${aws_eks_cluster.eks.name}-myapp-secrets"
#   policy = jsonencode({
#     Version = "2012-10-17"
#     Statement = [
#       {
#         Effect = "Allow"
#         Action = [
#           "secretsmanager:GetSecretValue",
#           "secretsmanager:DescribeSecret",
#           "*" # only for testing You can remove it later if needed
#         ]
#         //  Resource = var.rds_secret_arn # Restrict access to the specific secret ARN
#         Resource = "*" # only for testing You can specify a more restrictive ARN if needed
#       }
#     ]
#   })

# }


# resource "aws_iam_role_policy_attachment" "myapp_secrets" {
#   policy_arn = aws_iam_policy.myapp_secrets.arn
#   role       = aws_iam_role.myapp_secrets.name
# }

# resource "kubernetes_service_account" "myapp" {
#   metadata {
#     name      = "myapp"
#     namespace = "default"
#     annotations = {
#       "eks.amazonaws.com/role-arn" = aws_iam_role.myapp_secrets.arn
#     }
#   }
# }



