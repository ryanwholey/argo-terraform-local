variable "admin_password" {}
variable "slack_token" {}
variable "argocd_auth_token" {}
variable "circleci_token" {}

variable "circleci_organization" {
  default = "ryanwholey"
}

variable "local_argocd_url" {
  description = "Demos are faster not going through ngork"
}

variable "argocd_url" {
  description = "Internet accessable URL for the argo-cd server"
}

variable "test_app_staging_url" {}

variable "test_app_production_url" {}

variable "source_repo_url" {
  description = "Example: https://github.com/ryanwholey/test-app-config. Probably better to setup ssh"
}
