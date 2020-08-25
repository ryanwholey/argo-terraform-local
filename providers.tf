provider "helm" {}

provider "kubernetes" {}

provider "kubectl" {}

provider "circleci" {
  api_token    = var.circleci_token
  organization = var.circleci_organization
}
