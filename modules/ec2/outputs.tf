output "instance_id" {
  value = aws_instance.my_instance.id
}

output "private_ip" {
  value = aws_instance.my_instance.private_ip
}
