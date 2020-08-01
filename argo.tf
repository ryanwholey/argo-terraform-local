resource "kubernetes_namespace" "argo_cd" {
  metadata {
    name = "argocd"
  }
}

resource "helm_release" "argo_cd" {
  name       = "argo-cd"
  namespace  = kubernetes_namespace.argo_cd.metadata[0].name
  repository = "https://argoproj.github.io/argo-helm"
  chart      = "argo-cd"

  values = [
    jsonencode({
      configs = {
        secret = {
          argocdServerAdminPassword = bcrypt("admin")
        }
      }
    })
  ]
}

resource "kubernetes_manifest" "test_app" {
  provider = kubernetes-alpha

  manifest = {
    apiVersion = "argoproj.io/v1alpha1"
    kind       = "Application"
    metadata = {
      name      = "guestbook"
      namespace = kubernetes_namespace.argo_cd.metadata[0].name
    }
    spec = {
      project = "default"
      source = {
        repoURL        = "https://github.com/argoproj/argocd-example-apps.git"
        targetRevision = "HEAD"
        path           = "helm-guestbook"
      }
      destination = {
        server    = "https://kubernetes.default.svc"
        namespace = "default"
      }
    }
  }
}

# # data "kubernetes_service" "argo_server" {
# #   metadata {
# #     name      = "argo_ui"
# #     namespace = helm_release.spinnaker.metadata[0].namespace
# #   }
# # }
