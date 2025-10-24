# JENKINS (with permanent fixes for docker and kubectl)
resource "kubernetes_deployment" "jenkins" {
  metadata { name = "jenkins" }
  spec {
    replicas = 1
    selector { match_labels = { app = "jenkins" } }
    template {
      metadata { labels = { app = "jenkins" } }
      spec {
        security_context { run_as_user = 0 }
        container {
          name  = "jenkins"
          image = "jenkins/jenkins:lts"
          port { container_port = 8080 }
          port { container_port = 50000 }
          volume_mount {
            name       = "docker-socket"
            mount_path = "/var/run/docker.sock"
          }
          volume_mount {
            name       = "kubectl"
            mount_path = "/usr/local/bin/kubectl"
          }
          volume_mount {
            name       = "kube-config"
            mount_path = "/root/.kube"
          }
        }
        volume {
          name = "docker-socket"
          host_path { path = "/var/run/docker.sock" }
        }
        volume {
          name = "kubectl"
          host_path { path = "/usr/local/bin/kubectl" }
        }
        volume {
          name = "kube-config"
          host_path { path = "/home/zaarahirani/.kube" }
        }
      }
    }
  }
}
resource "kubernetes_service" "jenkins_service" {
  metadata { name = "jenkins-service" }
  spec {
    selector = { app = "jenkins" }
    port {
      name        = "http"
      port        = 8080
      target_port = 8080
      node_port   = 32000 # Permanent Port
    }
    type = "NodePort"
  }
}

# PROMETHEUS
resource "kubernetes_config_map" "prometheus_config" {
  metadata { name = "prometheus-config" }
  data = {
    "prometheus.yml" = <<-EOF
    global:
      scrape_interval: 15s
    scrape_configs:
      - job_name: 'kubernetes-pods'
        kubernetes_sd_configs:
          - role: pod
        relabel_configs:
          - source_labels: [__meta_kubernetes_pod_annotation_prometheus_io_scrape]
            action: keep
            regex: true
          - source_labels: [__meta_kubernetes_pod_annotation_prometheus_io_port]
            action: replace
            target_label: __address__
            regex: ([^:]+)(?::\d+)?;(\d+)
            replacement: $${1}:$${2}
    EOF
  }
}
resource "kubernetes_deployment" "prometheus" {
  metadata { name = "prometheus" }
  spec {
    replicas = 1
    selector { match_labels = { app = "prometheus" } }
    template {
      metadata { labels = { app = "prometheus" } }
      spec {
        container {
          name  = "prometheus"
          image = "prom/prometheus:v2.45.0"
          args  = ["--config.file=/etc/prometheus/prometheus.yml"]
          port { container_port = 9090 }
          volume_mount {
            name       = "config-volume"
            mount_path = "/etc/prometheus"
          }
        }
        volume {
          name = "config-volume"
          config_map { name = "prometheus-config" }
        }
      }
    }
  }
}
resource "kubernetes_service" "prometheus_service" {
  metadata { name = "prometheus-service" }
  spec {
    selector = { app = "prometheus" }
    port {
      port        = 9090
      target_port = 9090
      node_port   = 32002 # Permanent Port
    }
    type = "NodePort"
  }
}

# GRAFANA
resource "kubernetes_deployment" "grafana" {
  metadata { name = "grafana" }
  spec {
    replicas = 1
    selector { match_labels = { app = "grafana" } }
    template {
      metadata { labels = { app = "grafana" } }
      spec {
        container {
          name  = "grafana"
          image = "grafana/grafana:9.5.1"
          port { container_port = 3000 }
        }
      }
    }
  }
}
resource "kubernetes_service" "grafana_service" {
  metadata { name = "grafana-service" }
  spec {
    selector = { app = "grafana" }
    port {
      port        = 3000
      target_port = 3000
      node_port   = 32003 # Permanent Port
    }
    type = "NodePort"
  }
}

# PYTHON APPLICATION
resource "kubernetes_deployment" "selfhealing_app" {
  metadata { name = "selfhealing-app-deployment" }
  spec {
    replicas = 2
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
          name  = "selfhealing-app-container"
          image = "zaarahirani/selfhealing-app:initial"
          port { container_port = 5000 }
        }
      }
    }
  }
}
resource "kubernetes_service" "selfhealing_app_service" {
  metadata { name = "selfhealing-app-service" }
  spec {
    selector = { app = "selfhealing-app" }
    port {
      port        = 80
      target_port = 5000
      node_port   = 32004 # Permanent Port
    }
    type = "NodePort"
  }
}
