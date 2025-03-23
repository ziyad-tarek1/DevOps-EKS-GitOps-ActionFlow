

resource "time_sleep" "wait_for_kubernetes" {

  depends_on = [
    var.eks_dependency
  ]

  create_duration = "20s"
}
resource "kubernetes_namespace" "kube-namespace" {
  depends_on = [var.eks_dependency, time_sleep.wait_for_kubernetes]
  metadata {

    name = var.namespace
  }
}


resource "helm_release" "prometheus" {
  depends_on       = [kubernetes_namespace.kube-namespace, time_sleep.wait_for_kubernetes]
  name             = "prometheus"
  repository       = "https://prometheus-community.github.io/helm-charts"
  chart            = "kube-prometheus-stack"
  namespace        = kubernetes_namespace.kube-namespace.id
  create_namespace = true
  version          = var.chart_version
  values           = [file("${var.values_file}")]
  timeout          = 2000


  /*set {
    name  = "podSecurityPolicy.enabled"
    value = true
  }

  set {
    name  = "server.persistentVolume.enabled"
    value = false
  }

  set {
    name = "server\\.resources"
    value = yamlencode({
      limits = {
        cpu    = "200m"
        memory = "50Mi"
      }
      requests = {
        cpu    = "100m"
        memory = "30Mi"
      }
    })
  }*/

}