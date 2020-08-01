provider "helm" {}
provider "kubernetes" {}

provider "kubernetes-alpha" {
  config_path = "~/.kube/config" // path to kubeconfig
}