data "circleci_context" "publish" {
  name         = "publish"
  organization = var.circleci_organization
} 

resource "circleci_context_environment_variable" "publish_argocd_server" {
  variable   = "ARGOCD_SERVER"
  value      = var.argocd_url
  context_id = data.circleci_context.publish.id
}

resource "circleci_context_environment_variable" "publish_argocd_auth_token" {
  variable   = "ARGOCD_AUTH_TOKEN"
  value      = var.argocd_auth_token
  context_id = data.circleci_context.publish.id
}
