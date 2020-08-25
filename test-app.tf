resource "kubectl_manifest" "test_app_project" {
  yaml_body = yamlencode({
    apiVersion = "argoproj.io/v1alpha1"
    kind       = "AppProject"
    metadata = {
      name      = "test-app-project"
      namespace = kubernetes_namespace.argo.metadata[0].name
      finalizers = [
        "resources-finalizer.argocd.argoproj.io" # Finalizer that ensures that project is not deleted until it is not referenced by any application
      ]
    }
    spec = {
      description = "Project for all test apps"
      sourceRepos = [ "${var.source_repo_url}" ]
      destinations = [
        {
          namespace = "default"
          server    = "https://kubernetes.default.svc"
        }
      ]
      clusterResourceWhitelist = [
        {
          group = "*"
          kind  = "*"
        }
      ]
      orphanedResources = {
        warn = false
      }
    }
  })
  depends_on = [helm_release.argo_cd]
}

resource "kubectl_manifest" "test_app" {
  for_each = toset(["staging", "production"])
  
  yaml_body = yamlencode({
    apiVersion = "argoproj.io/v1alpha1"
    kind       = "Application"
    metadata = {
      name      = "test-app-${each.value}"
      namespace = kubernetes_namespace.argo.metadata[0].name
      labels = {
        environment = "${each.value}"
      }
      finalizers = [
        "resources-finalizer.argocd.argoproj.io"
      ]
    }
    spec = {
      project = "test-app-project"
      source = {
        repoURL        = "${var.source_repo_url}"
        targetRevision = "${each.value}"
        path           = "./"
        helm = {
          parameters = [
            {
              name = "service.type"
              value = "NodePort"
            },
            {
              name = "nameOverride"
              value = "test-app-${each.value}"
            },
            {
              name = "ingress.enabled"
              value = "false"
            },
            {
              name = "hooks.enabled"
              value = "false"
            },
            {
              name = "hooks.slackToken"
              value = ""
            },
          ]
        }
      }
      destination = {
        server    = "https://kubernetes.default.svc"
        namespace = "default"
      }
      # syncPolicy = {
      #   automated = {
      #     prune = true
      #   }
      # }
    }
  })
  depends_on = [helm_release.argo_cd]
}
