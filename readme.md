# Argo Terraform

A Terraform project that creates an ArgoCD deployment in minikube.

## Setup

- `minikube start && eval $(minikube docker-env)`
- Add the appropriate fields to `env-example` and source it `source ./env-example`, leaving the argocd stuff blank for now
- `terraform init`
- `terraform apply`
- Create an ArgoCD machine user and [get an auth token](https://argoproj.github.io/argo-cd/operator-manual/security/)
- Run ngrok on the local argocd server to the public argocd url
- Fill out the argocd env vars and run `terraform apply`
- Check out the [test-app CircleCI config](https://github.com/ryanwholey/test-app/blob/master/.circleci/config.yml) to see an example of pushing commits through a repository
