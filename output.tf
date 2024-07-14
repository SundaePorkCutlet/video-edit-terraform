output "jenkins_private_ip" {
  value = module.jenkins_instance.private_ip
}

output "ecr_backend_repository_url" {
  value = module.ecr_backend.repository_url
}
