resource "kubernetes_secret" "git_ssh" {
  metadata {
    name      = "git-ssh"
    namespace = kubernetes_namespace.argo_events.metadata[0].name
  }

  data = {
    key = file(var.github_ssh_private_key_file)
  }
}

resource "kubernetes_secret" "git_known_hosts" {
  metadata {
    name      = "git-known-hosts"
    namespace = kubernetes_namespace.argo_events.metadata[0].name
  }

  data = {
    ssh_known_hosts = "github.com,192.30.255.113 ssh-rsa AAAAB3NzaC1yc2EAAAABIwAAAQEAq2A7hRGmdnm9tUDbO9IDSwBK6TbQa+PXYPCPy6rbTrTtw7PHkccKrpp0yVhp5HdEIcKr6pLlVDBfOLX9QUsyCOV0wzfjIJNlGEYsdlLJizHhbn2mUjvSAHQqZETYP81eFzLQNnPHt4EVVUh7VfDESU84KezmD5QlWpXLmvU31/yMf+Se8xhHTvKSCZIFImWwoG6mbUoWf9nzpIoaSjB+weqqUUmpaaasXVal72J+UX2B+2RPW3RcT0eOzQgqlJL3RKrTJvdsjE3JEAvGq3lGHSZXy28G3skua2SmVi/w4yCE6gbODqnTWlg7+wC604ydGXA8VJiS5ap43JXiUFFAaQ=="
  }
}

resource "kubernetes_secret" "git_access" {
  metadata {
    name      = "github-access"
    namespace = kubernetes_namespace.argo_events.metadata[0].name
  }

  data = {
    token = var.github_token
  }
}

resource "kubernetes_secret" "git_credentials" {
  metadata {
    name      = "git-credentials"
    namespace = kubernetes_namespace.argo_events.metadata[0].name
  }

  data = {
    GIT_TOKEN = var.github_token
    GIT_USER = var.github_user
  }
}

resource "kubectl_manifest" "github" {
  yaml_body = <<-EOF
    apiVersion: argoproj.io/v1alpha1
    kind: EventSource
    metadata:
      name: github
      namespace: ${kubernetes_namespace.argo_events.metadata[0].name}
    spec:
      service:
        ports:
          - port: 12000
            targetPort: 12000
      github:
        test-app-config:
          namespace: ${kubernetes_namespace.argo_events.metadata[0].name}
          owner: ryanwholey
          repository: test-app-config
          # Github will send events to following port and endpoint
          webhook:
            endpoint: /push
            port: "12000"
            method: POST
            url: http://908449e587bd.ngrok.io
          events:
            - "*"
          apiToken:
            name: github-access
            key: token

          # type of the connection between event-source and Github.
          # You should set it to false to avoid man-in-the-middle and other attacks.
          insecure: true

          active: true
          contentType: json
  EOF
  
  depends_on = [null_resource.argo_events]
}

resource "kubectl_manifest" "github_sensor" {
  yaml_body = <<-EOF
    apiVersion: argoproj.io/v1alpha1
    kind: Sensor
    metadata:
      name: github
      namespace: ${kubernetes_namespace.argo_events.metadata[0].name}
    spec:
      template:
        serviceAccountName: argo-events-sa
      dependencies:
        - name: test-dep
          eventSourceName: github
          eventName: test-app-config
          filters:
            name: data-filter
            data:
              - path: body.ref
                type: string
                comparator: "="
                value:
                  - "refs/heads/master"
      triggers:
        - template:
            name: github-workflow-trigger
            k8s:
              group: argoproj.io
              version: v1alpha1
              resource: workflows
              operation: create
              source:
                resource:
                  apiVersion: argoproj.io/v1alpha1
                  kind: Workflow
                  metadata:
                    generateName: github-
                  spec:
                    entrypoint: release-staging
                    serviceAccountName: argo-events-sa
                    arguments:
                      parameters:
                        - name: owner
                          value: "-"
                        - name: repository
                          value: "-"
                    templates:
                    - name: release-staging
                      inputs:
                        parameters:
                          - name: owner
                          - name: repository
                      container:
                        image: ryanwholey/merge-release:latest
                        command: 
                          - /merge-release.sh
                        args: 
                          - "{{inputs.parameters.owner}}"
                          - "{{inputs.parameters.repository}}"
                          - "staging"
                        envFrom:
                          - secretRef:
                              name: ${kubernetes_secret.git_credentials.metadata[0].name}
              parameters:
                - src:
                    dependencyName: test-dep
                    dataKey: body.repository.owner.name
                  dest: spec.arguments.parameters.0.value
                - src:
                    dependencyName: test-dep
                    dataKey: body.repository.name
                  dest: spec.arguments.parameters.1.value
  EOF

  depends_on = [null_resource.argo_events]
}

  #      # webhookSecret refers to K8s secret that stores the github hook secret
  #      # +optional
  #      webhookSecret:
  #        # Name of the K8s secret that contains the hook secret
  #        name: github-access
  #        # Key within the K8s secret whose corresponding value (must be base64 encoded) is hook secret
  #        key: secret