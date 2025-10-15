resource "kubernetes_deployment" "selfhealing_app" {
  metadata {
    name   = "selfhealing-app"
    labels = { app = "selfhealing-app" }
  }
  spec {
    replicas = 3
    selector { match_labels = { app = "selfhealing-app" } }
    template {
      metadata {
        labels = { app = "selfhealing-app" }
        annotations = {
          "prometheus.io/scrape" = "true"
          "prometheus.io/port"   = "5000"
        }
      }
      spec {
        container {
          name  = "selfhealing-app"
          image = "zaarahirani/selfhealing-app:latest"
          port { container_port = 5000 }
        }
      }
    }
  }
}

resource "kubernetes_service" "selfhealing_svc" {
  metadata {
    name = "selfhealing-svc"
  }
  spec {
    selector = {
      app = "selfhealing-app"
    }
    port {
      port        = 5000
      target_port = 5000
    }
    type = "ClusterIP"
  }
}
