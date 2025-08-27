resource "helm_release" "ingress-nginx" {
  name              = "ingress-nginx"
  namespace         = "ingress"
  create_namespace  = true

  repository        = "https://kubernetes.github.io/ingress-nginx"
  chart             = "ingress-nginx"

  values = [file("values.yml")]
}