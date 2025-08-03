provider "helm" {
  kubernetes = {
    # Path to your kubeconfig file
    config_path = "/mnt/c/Users/ilham/.kube/config"
  }
}
