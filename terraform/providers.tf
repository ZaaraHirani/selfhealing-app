terraform {
  required_providers {
    kubernetes = {
      source  = "hashicorp/kubernetes"
      version = "2.20.0"
    }
  }
}
provider "kubernetes" {
  config_path    = "~/.kube/config"
  config_context = "minikube"
}
