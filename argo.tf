resource "kubernetes_namespace" "argo" {
  metadata {
    name = "argo"
  }
}

resource "kubernetes_namespace" "argo_events" {
  metadata {
    name = "argo-events"
  }
}

resource "helm_release" "argo" {
  name       = "argo"
  namespace  = kubernetes_namespace.argo.metadata[0].name
  repository = "https://argoproj.github.io/argo-helm"
  chart      = "argo"

  values = []
}

resource "null_resource" "argo_events" {
  provisioner "local-exec" {
    command = <<-EOF
      kubectl apply -n ${kubernetes_namespace.argo_events.metadata[0].name} -f https://raw.githubusercontent.com/argoproj/argo-events/stable/manifests/install.yaml
      kubectl apply -n ${kubernetes_namespace.argo_events.metadata[0].name} -f https://raw.githubusercontent.com/argoproj/argo-events/stable/examples/eventbus/native.yaml
    EOF
  }
}

# resource "kubectl_manifest" "webhook" {
#   yaml_body = <<-EOF
#     apiVersion: argoproj.io/v1alpha1
#     kind: EventSource
#     metadata:
#       name: webhook
#       namespace: ${kubernetes_namespace.argo_events.metadata[0].name}
#     spec:
#       service:
#         ports:
#           - port: 12000
#             targetPort: 12000
#       webhook:
#         example:
#           port: "12000"
#           endpoint: /
#           method: POST
#   EOF

#   depends_on = [null_resource.argo_events]
# }

# resource "helm_release" "argo_events" {
#   name       = "argo-events"
#   namespace  = kubernetes_namespace.argo_events.metadata[0].name
#   repository = "https://argoproj.github.io/argo-helm"
#   chart      = "argo-events"

#   values = [
#     jsonencode({
#       singleNamespace = false
#     })
#   ]
# }

resource "helm_release" "argo_rollouts" {
  name       = "argo-rollouts"
  namespace  = kubernetes_namespace.argo.metadata[0].name
  repository = "https://argoproj.github.io/argo-helm"
  chart      = "argo-rollouts"

  values = []
}

resource "helm_release" "argo_cd" {
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

