resource "aws_ecr_repository" "my_ecr" {
  name = var.name
  image_scanning_configuration {
    scan_on_push = true
  }
  image_tag_mutability = "MUTABLE"
  tags = {
    Name = var.name
  }
}

output "repository_url" {
  value = aws_ecr_repository.my_ecr.repository_url
}
