resource "kubernetes_namespace" "argo" {
  metadata {
    name = "argocd"
  }
}

resource "helm_release" "argo" {
  name       = "argo-cd"
  namespace  = kubernetes_namespace.argo.metadata[0].name
  repository = "https://argoproj.github.io/argo-helm"
  chart      = "argo-cd"

  values = [
    jsonencode({
      configs = {
        secret = {
          argocdServerAdminPassword = bcrypt(var.argo_admin_password)
        }
      }
      server = {
        service = { // Minikube only
          type = "NodePort"
        }
        extraArgs = [
          "--insecure" # would be nice to use https, even though we terminate at the LB
        ]
      }
    })
  ]
}
