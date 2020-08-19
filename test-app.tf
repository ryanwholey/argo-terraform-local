# resource "kubectl_manifest" "test_app_project" {
#   yaml_body = yamlencode({
#     apiVersion = "argoproj.io/v1alpha1"
#     kind = "AppProject"
#     metadata = {
#       name = "test-app-project"
#       namespace = kubernetes_namespace.argo.metadata[0].name
#       # Finalizer that ensures that project is not deleted until it is not referenced by any application
#       finalizers = [
#         "resources-finalizer.argocd.argoproj.io"
#       ]
#     }
#     spec = {
#       description = "Project for all test apps"
#       sourceRepos = [
#         "https://github.com/ryanwholey/test-app-helm"
#       ]
#       destinations = [
#         {
#           namespace = "default"
#           server = "https://kubernetes.default.svc"
#         }
#       ]
#       clusterResourceWhitelist = [
#         {
#           group = "*"
#           kind = "*"
#         }
#       ]
#       orphanedResources = {
#         warn = false
#       }
#     }
#   })
#   depends_on = [helm_release.argo]
# }

# resource "kubectl_manifest" "test_app_staging" {
#   yaml_body = yamlencode({
#     apiVersion = "argoproj.io/v1alpha1"
#     kind       = "Application"
#     metadata = {
#       name      = "test-app-staging"
#       namespace = kubernetes_namespace.argo.metadata[0].name
#       labels = {
#         environment = "staging"
#       }
#       finalizers = [
#         "resources-finalizer.argocd.argoproj.io"
#       ]
#     }
#     spec = {
#       project = "test-app-project"
#       source = {
#         repoURL        = "https://github.com/ryanwholey/test-app-helm.git"
#         targetRevision = "HEAD"
#         path           = "./"
#         helm = {
#           parameters = [
#             {
#               name = "service.type"
#               value = "NodePort"
#             },
#             {
#               name = "nameOverride"
#               value = "test-app-staging"
#             },
#             {
#               name = "ingress.enabled"
#               value = "false"
#             }
#           ]
#         }
#       }
#       destination = {
#         server    = "https://kubernetes.default.svc"
#         namespace = "default"
#       }
#       syncPolicy = {
#         automated = {
#           prune = true
#         }
#       }
#     }
#   })
#   depends_on = [helm_release.argo]
# }

# resource "kubectl_manifest" "test_app_production" {
#   yaml_body = yamlencode({
#     apiVersion = "argoproj.io/v1alpha1"
#     kind       = "Application"
#     metadata = {
#       name      = "test-app-production"
#       namespace = kubernetes_namespace.argo.metadata[0].name
#       labels = {
#         environment = "production"
#       }
#       finalizers = [
#         "resources-finalizer.argocd.argoproj.io"
#       ]
#     }
#     spec = {
#       project = "test-app-project"
#       source = {
#         repoURL        = "https://github.com/ryanwholey/test-app-helm.git"
#         targetRevision = "HEAD"
#         path           = "./"
#         helm = {
#           parameters = [
#             {
#               name = "service.type"
#               value = "NodePort"
#             },
#             {
#               name = "nameOverride"
#               value = "test-app-production"
#             },
#             {
#               name = "ingress.enabled"
#               value = "false"
#             }
#           ]
#         }
#       }
#       destination = {
#         server    = "https://kubernetes.default.svc"
#         namespace = "default"
#       }
#     }
#   })
  
#   depends_on = [helm_release.argo]
# }

# # resource "kubectl_manifest" "test_app_production" {
# #   yaml_body = yamlencode({
# #     apiVersion = "argoproj.io/v1alpha1"
# #     kind       = "Application"
# #     metadata = {
# #       name      = "test-app-production"
# #       namespace = kubernetes_namespace.argo.metadata[0].name
# #     }
# #     spec = {
# #       project = "default"
# #       source = {
# #         repoURL        = "https://github.com/ryanwholey/test-app-helm.git"
# #         targetRevision = "HEAD"
# #         path           = "test-app"
# #       }
# #       destination = {
# #         server    = "https://kubernetes.default.svc"
# #         namespace = "default"
# #       }
# #     }
# #   })
# # }
