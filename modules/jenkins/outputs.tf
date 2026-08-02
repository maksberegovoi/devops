output "jenkins_url" {
  description = "Jenkins external LoadBalancer URL"
  value       = "http://${helm_release.jenkins.name}.${var.namespace}.svc.cluster.local"
}