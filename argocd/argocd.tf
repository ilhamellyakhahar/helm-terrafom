resource "helm_release" "argocd" {
  name              = "argocd"
  namespace         = "argocd"
  create_namespace  = true

  repository        = "https://argoproj.github.io/argo-helm"
  chart             = "argo-cd"

  values = [file("values.yml")]
}