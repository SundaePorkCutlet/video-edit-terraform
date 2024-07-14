resource "aws_subnet" "my_subnet" {
  vpc_id            = var.vpc_id
  cidr_block        = var.cidr_block
  availability_zone = var.availability_zone
  tags = {
    Name = var.name
  }
}

output "subnet_id" {
  value = aws_subnet.my_subnet.id
}
