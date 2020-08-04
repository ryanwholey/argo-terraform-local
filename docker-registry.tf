resource "helm_release" "docker_registry" {
  name       = "docker-registry"
  namespace  = "default"
  repository = "https://kubernetes-charts.storage.googleapis.com"
  chart      = "docker-registry"

  values = [
    jsonencode({
      secrets = {
        # htpasswd = module.basic_auth.password
      }
      service = {
        type = "NodePort"
      }
    })
  ]
}

# module "basic_auth" {
#   source  = "vmfarms/basic-auth/kubernetes"
#   version = "0.1.1"
  
#   name      = "docker-registry-auth"
#   namespace = "default"
# }
