resource "aws_vpc" "my_vpc" {
  cidr_block = var.cidr_block
  tags = {
    Name = var.name
  }
}

output "vpc_id" {
  value = aws_vpc.my_vpc.id
}
