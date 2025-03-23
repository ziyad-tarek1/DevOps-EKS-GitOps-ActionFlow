
resource "helm_release" "application" {
  name             = var.app_name
  namespace        = var.namespace
  create_namespace = var.create_namespace
  repository       = var.repository
  chart            = var.chart
  version          = var.chart_version
  values           = [file(var.values_file)]
  depends_on       = [var.eks_dependency]

}


