locals {
  projectName = var.project_name
  clusterName = var.cluster_name
}

////////////////////////////////////////////////////////////////////////////////////////////////

module "vpc-1" {
  source                = "../module/vpc/"
  vpc_cidr_block        = "10.0.0.0/16"
  dns_hostnames_stateus = true
  dns_support_stateus   = true

  project_name = local.projectName
  eks_name     = local.clusterName
  cluster_type = "shared"

  private_subnets = [
    { cidr = "10.0.1.0/24", az = "us-east-1a" },
    { cidr = "10.0.2.0/24", az = "us-east-1b" }
  ]

  public_subnets = [
    { cidr = "10.0.3.0/24", az = "us-east-1a" },
    { cidr = "10.0.4.0/24", az = "us-east-1b" }
  ]

  create_nat_gateway = true
}
////////////////////////////////////////////////////////////////////////////////////////////////


module "eks" {
  source                  = "../module/eks/"
  project_name            = local.projectName
  eks_name                = local.clusterName
  eks_version             = "1.31"
  private_subnets         = module.vpc-1.private_subnet_ids
  public_subnets          = module.vpc-1.public_subnet_ids
  instance_types          = ["t2.medium"]
  desired_size            = 2
  max_size                = 10
  min_size                = 2
  endpoint_private_access = false
  endpoint_public_access  = true
  region                  = var.region
  vpc_id                  = module.vpc-1.vpc_id

}

////////////////////////////////////////////////////////////////////////////////////////////////


module "bastion" {
  source             = "../module/bastion_host"
  project_name       = local.projectName
  instance_type      = "t2.micro"
  public_subnet_id   = module.vpc-1.public_subnet_ids[0]
  vpc_id             = module.vpc-1.vpc_id
  entry_point_script = "../data/bastion_data/bastion-bootstrap.sh"
  provisioner_script = "../data/bastion_data/bastion-provisioner.sh" 
  eks_dependency     = [module.eks.eks_cluster_name]

}

////////////////////////////////////////////////////////////////////////////////////////////////

module "metrics_server" {
  source           = "../module/app"
  app_name         = "metrics-server"
  namespace        = "kube-system"
  create_namespace = true
  chart            = "metrics-server"
  repository       = "https://kubernetes-sigs.github.io/metrics-server/"
  chart_version    = "3.12.1"
  values_file      = "../data/metrics_server_data/metrics-server.yaml"
  eks_dependency   = module.eks.eks_node_group_dependency

}

////////////////////////////////////////////////////////////////////////////////////////////////

module "autoscaler" {
  source                       = "../module/autoscaler"
  cluster_name                 = module.eks.eks_cluster_name
  region                       = var.region
  namespace                    = "kube-system"
  service_account_name         = "cluster-autoscaler"
  policy_file_path             = "../data/autoscaler_data/policy-autoscaler.json"
  assume_role_policy_file_path = "../data/autoscaler_data/podrole-autoscaler.json"
}

////////////////////////////////////////////////////////////////////////////////////////////////

module "aws_alb" {
  source                       = "../module/alb"
  cluster_name                 = module.eks.eks_cluster_name
  vpc_id                       = module.vpc-1.vpc_id
  region                       = var.region
  namespace                    = "kube-system"
  service_account_name         = "aws-load-balancer-controller"
  repository                   = "https://aws.github.io/eks-charts"
  chart                        = "aws-load-balancer-controller"
  chart_version                = "1.7.2"
  policy_file_path             = "../data/alb_data/policy-autoscaler.json"
  assume_role_policy_file_path = "../data/alb_data/podrole-autoscaler.json"
  eks_dependency               = [module.autoscaler.helm_release_name, module.eks.eks_cluster_name]

}


////////////////////////////////////////////////////////////////////////////////////////////////


module "prometheus" {
  source         = "../module/promethous-and-grafana"
  namespace      = "prometheus"
  chart_version  = "45.10.0"
  values_file    = "../data/prometheus_data/promethousvalues.yaml"
  eks_dependency = module.eks.eks_node_group_dependency
}

////////////////////////////////////////////////////////////////////////////////////////////////


module "argocd" {
  source           = "../module/app"
  app_name         = "argocd"
  namespace        = "argocd"
  create_namespace = true
  chart            = "argo-cd"
  repository       = "https://argoproj.github.io/argo-helm"
  chart_version    = "5.46.0"
  values_file      = "../data/argocd_data/argocd.yaml"
  eks_dependency   = module.eks.eks_node_group_dependency

}


////////////////////////////////////////////////////////////////////////////////////////////////

module "ecr_repo" {
  source       = "../module/ecr"
  ecr_name     = "skyebank"
  scan_on_push = true
}

////////////////////////////////////////////////////////////////////////////////////////////////
