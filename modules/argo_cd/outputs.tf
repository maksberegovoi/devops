output "argocd_server" {
  description = "Argo CD Server LoadBalancer domain"
  value       = "http://${helm_release.argocd.name}-server.${var.namespace}.svc.cluster.local"
}