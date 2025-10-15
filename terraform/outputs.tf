output "selfhealing_service_ip" {
  value = kubernetes_service.selfhealing_svc.spec[0].cluster_ip
}
