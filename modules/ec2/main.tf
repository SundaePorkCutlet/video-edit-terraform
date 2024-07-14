resource "aws_instance" "my_instance" {
  ami                    = var.ami
  instance_type          = var.instance_type
  subnet_id              = var.subnet_id
  vpc_security_group_ids = var.security_group_ids
  key_name               = var.key_name

  tags = {
    Name = var.name
  }
}

output "instance_id" {
  value = aws_instance.my_instance.id
}

output "private_ip" {
  value = aws_instance.my_instance.private_ip
}
