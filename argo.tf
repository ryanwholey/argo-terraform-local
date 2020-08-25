resource "kubernetes_namespace" "argo" {
  metadata {
    name = "argo"
  }
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
          argocdServerAdminPassword = bcrypt(var.admin_password)
        }
      }
      server = {
        service = { # Minikube only
          type = "NodePort"
        }
        extraArgs = [
          "--insecure" # would be nice to use https, even though we terminate at the LB
        ]
      }
    })
  ]
}

resource "helm_release" "argocd_notifications" {
  name       = "argocd-notifications"
  namespace  = kubernetes_namespace.argo.metadata[0].name
  repository = "https://argoproj.github.io/argo-helm"
  chart      = "argocd-notifications"

  values = [
    jsonencode({
      argocdUrl = var.local_argocd_url
      secret = {
        notifiers = {
          slack = {
            enabled  = true
            token    = var.slack_token
            username = "argo"
          }
        }
      }
      subscriptions = [
        {
          recipients = [
            "slack:dev-spinnaker"
          ]
          trigger = "on-deploy-succeeded"
        },
        {
          recipients = [
            "slack:dev-spinnaker"
          ]
          trigger = "on-deploy-failed"
        },
      ]
      triggers = [
        {
          name    = "sync-operation-succeeded"
          enabled = true
          condition = "app.status.operationState.phase in ['Succeeded'] and app.status.health.status in ['Healthy']"
          template = "app-deploy-good"
        },
        {
          name    = "sync-operation-failed"
          enabled = false
          condition = "app.status.health.status not in ['Healthy', 'Progressing']"
          template = "app-deploy-bad"
        },
      ]
      templates = [
        {
          name  = "app-deploy-good"
          title = "Application {{.app.metadata.name}} has released"
          body = <<-EOF
            :white_check_mark: Application {{.app.metadata.name}} released.
          EOF
          slack = {
            attachments = <<-EOF
              [{
                "title": "{{.app.metadata.name}}",
                "title_link": "{{.context.argocdUrl}}/applications/{{.app.metadata.name}}",
                "color": "#18be52",
                "fields": [
                  {
                    "title": "Sync status",
                    "value": "{{.app.status.sync.status}}",
                    "short": true
                  }, {
                    "title": "Deployment",
                    "value": "${var.test_app_staging_url}",
                    "short": true
                  }, {
                    "title": "Release details",
                    "value": "<{{.context.argocdUrl}}/applications/{{.app.metadata.name}}|{{.app.metadata.name}}>",
                    "short": true
                  }
                ]
              }]
            EOF
          }
        },
        {
          name  = "app-deploy-bad"
          title = "Application {{.app.metadata.name}} has failed"
          body = <<-EOF
            :red_circle: Application {{.app.metadata.name}}.
            Application details: {{.context.argocdUrl}}/applications/{{.app.metadata.name}}.
          EOF
          slack = {
            attachments = <<-EOF
              [{
                "title": "{{.app.metadata.name}}",
                "title_link": "{{.context.argocdUrl}}/applications/{{.app.metadata.name}}",
                "color": "#FF0000",
                "fields": [
                  {
                    "title": "Sync status",
                    "value": "{{.app.status.sync.status}}",
                    "short": true
                  }, {
                    "title": "Deployment",
                    "value": "${var.test_app_staging_url}",
                    "short": true
                  }, {
                    "title": "Release details",
                    "value": "<{{.context.argocdUrl}}/applications/{{.app.metadata.name}}|{{.app.metadata.name}}>",
                    "short": true
                  }
                ]
              }]
            EOF
          }
        }
      ]
    })
  ]
}

