provider "aws" {
  region = "ap-northeast-2" # 서울 리전
}

resource "aws_vpc" "my_vpc" {
  cidr_block = "10.1.0.0/16"
  tags = {
    Name = "my-vpc"
  }
}

resource "aws_subnet" "my_public_subnet_a" {
  vpc_id            = aws_vpc.my_vpc.id
  cidr_block        = "10.1.1.0/26"
  availability_zone = "ap-northeast-2a"
  tags = {
    Name = "my-public-subnet-a"
  }
}

resource "aws_subnet" "my_public_subnet_c" {
  vpc_id            = aws_vpc.my_vpc.id
  cidr_block        = "10.1.1.64/26"
  availability_zone = "ap-northeast-2c"
  tags = {
    Name = "my-public-subnet-c"
  }
}

resource "aws_subnet" "my_private_subnet_app_a" {
  vpc_id            = aws_vpc.my_vpc.id
  cidr_block        = "10.1.1.128/27"
  availability_zone = "ap-northeast-2a"
  tags = {
    Name = "my-private-subnet-app-a"
  }
}

resource "aws_subnet" "my_private_subnet_db_a" {
  vpc_id            = aws_vpc.my_vpc.id
  cidr_block        = "10.1.1.192/27"
  availability_zone = "ap-northeast-2a"
  tags = {
    Name = "my-private-subnet-db-a"
  }
}

resource "aws_subnet" "my_private_subnet_app_c" {
  vpc_id            = aws_vpc.my_vpc.id
  cidr_block        = "10.1.1.160/27"
  availability_zone = "ap-northeast-2c"
  tags = {
    Name = "my-private-subnet-app-c"
  }
}

resource "aws_subnet" "my_private_subnet_db_c" {
  vpc_id            = aws_vpc.my_vpc.id
  cidr_block        = "10.1.1.224/27"
  availability_zone = "ap-northeast-2c"
  tags = {
    Name = "my-private-subnet-db-c"
  }
}

resource "aws_internet_gateway" "my_igw" {
  vpc_id = aws_vpc.my_vpc.id
  tags = {
    Name = "my-igw"
  }
}

resource "aws_nat_gateway" "my_nat_gateway" {
  allocation_id = aws_eip.my_eip.id
  subnet_id     = aws_subnet.my_public_subnet_a.id
  tags = {
    Name = "my-nat-gateway"
  }
}

resource "aws_eip" "my_eip" {
  domain = "vpc"
}

resource "aws_route_table" "public_rt" {
  vpc_id = aws_vpc.my_vpc.id
  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.my_igw.id
  }
  tags = {
    Name = "public-rt"
  }
}

resource "aws_route_table_association" "public_rt_a" {
  subnet_id      = aws_subnet.my_public_subnet_a.id
  route_table_id = aws_route_table.public_rt.id
}

resource "aws_route_table_association" "public_rt_c" {
  subnet_id      = aws_subnet.my_public_subnet_c.id
  route_table_id = aws_route_table.public_rt.id
}

resource "aws_route_table" "private_rt" {
  vpc_id = aws_vpc.my_vpc.id
  route {
    cidr_block     = "0.0.0.0/0"
    nat_gateway_id = aws_nat_gateway.my_nat_gateway.id
  }
  tags = {
    Name = "private-rt"
  }
}

resource "aws_route_table_association" "private_rt_app_a" {
  subnet_id      = aws_subnet.my_private_subnet_app_a.id
  route_table_id = aws_route_table.private_rt.id
}

resource "aws_route_table_association" "private_rt_db_a" {
  subnet_id      = aws_subnet.my_private_subnet_db_a.id
  route_table_id = aws_route_table.private_rt.id
}

resource "aws_route_table_association" "private_rt_app_c" {
  subnet_id      = aws_subnet.my_private_subnet_app_c.id
  route_table_id = aws_route_table.private_rt.id
}

resource "aws_route_table_association" "private_rt_db_c" {
  subnet_id      = aws_subnet.my_private_subnet_db_c.id
  route_table_id = aws_route_table.private_rt.id
}

resource "aws_security_group" "openvpn_sg" {
  vpc_id = aws_vpc.my_vpc.id
  ingress {
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = [var.my_ip]
  }
  ingress {
    from_port   = 943
    to_port     = 943
    protocol    = "tcp"
    cidr_blocks = [var.my_ip]
  }
  ingress {
    from_port   = 1194
    to_port     = 1194
    protocol    = "udp"
    cidr_blocks = [var.my_ip]
  }
  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = [var.my_ip]
  }
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
  tags = {
    Name = "openvpn-sg"
  }
}

resource "aws_instance" "openvpn" {
  ami                    = "ami-09a093fa2e3bfca5a" # OpenVPN Access Server AMI ID
  instance_type          = "t2.small"
  subnet_id              = aws_subnet.my_public_subnet_a.id
  vpc_security_group_ids = [aws_security_group.openvpn_sg.id]
  key_name               = var.my_key_name

  tags = {
    Name = "OpenVPN-Server"
  }
}

resource "aws_eip" "openvpn_eip" {
  instance = aws_instance.openvpn.id
  domain   = "vpc"
  tags = {
    Name = "OpenVPN-EIP"
  }
}

# 보안 그룹: 프라이빗 서브넷의 EC2 인스턴스 접근 허용 (Bastion 서버에서만 접근 가능)
resource "aws_security_group" "private_ec2_sg" {
  vpc_id = aws_vpc.my_vpc.id
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
  tags = {
    Name = "private-ec2-sg"
  }
}

# Bastion 서버 보안 그룹에서 프라이빗 EC2 보안 그룹으로의 접근 허용
resource "aws_security_group_rule" "allow_bastion_to_private" {
  type                     = "ingress"
  from_port                = 22
  to_port                  = 22
  protocol                 = "tcp"
  security_group_id        = aws_security_group.private_ec2_sg.id
  source_security_group_id = aws_security_group.openvpn_sg.id
}

# Jenkins 서버 보안 그룹에서 8080 포트 접근 허용
resource "aws_security_group_rule" "allow_bastion_to_jenkins" {
  type                     = "ingress"
  from_port                = 8080
  to_port                  = 8080
  protocol                 = "tcp"
  security_group_id        = aws_security_group.private_ec2_sg.id
  source_security_group_id = aws_security_group.openvpn_sg.id
}

# 프라이빗 서브넷에 Jenkins 서버 생성
resource "aws_instance" "jenkins" {
  ami                    = "ami-01ed8ade75d4eee2f" # Ubuntu 22.04 LTS AMI ID
  instance_type          = "t2.micro"
  subnet_id              = aws_subnet.my_private_subnet_app_a.id
  vpc_security_group_ids = [aws_security_group.private_ec2_sg.id]
  key_name               = var.my_key_name

  tags = {
    Name = "jenkins"
  }
}

output "jenkins_private_ip" {
  value = aws_instance.jenkins.private_ip
}

# 프라이빗 서브넷에 Video Edit 서버 생성
resource "aws_instance" "video_edit_ec2" {
  ami                    = "ami-01ed8ade75d4eee2f" # Ubuntu 22.04 LTS AMI ID
  instance_type          = "t2.micro"
  subnet_id              = aws_subnet.my_private_subnet_app_a.id
  vpc_security_group_ids = [aws_security_group.private_ec2_sg.id]
  key_name               = var.my_key_name

  tags = {
    Name = "video-edit-ec2"
  }
}

resource "aws_eip" "video_edit_ec2_eip" {
  instance = aws_instance.video_edit_ec2.id
  domain   = "vpc"
  tags = {
    Name = "video-edit-ec2-eip"
  }
}

output "video_edit_ec2_private_ip" {
  value = aws_instance.video_edit_ec2.private_ip
}

output "video_edit_ec2_eip" {
  value = aws_eip.video_edit_ec2_eip.public_ip
}

resource "aws_ecr_repository" "my_ecr_frontend" {
  name = "my-ecr-frontend"
  image_scanning_configuration {
    scan_on_push = true
  }
  image_tag_mutability = "MUTABLE"
  tags = {
    Name = "my-ecr-front"
  }
}

resource "aws_ecr_repository" "my_ecr_backend" {
  name = "my-ecr-backend"
  image_scanning_configuration {
    scan_on_push = true
  }
  image_tag_mutability = "MUTABLE"
  tags = {
    Name = "my-ecr-back"
  }
}

output "ecr_frontend_repository_url" {
  value = aws_ecr_repository.my_ecr_frontend.repository_url
}

output "ecr_backend_repository_url" {
  value = aws_ecr_repository.my_ecr_backend.repository_url
}

output "openvpn_eip" {
  value = aws_eip.openvpn_eip.public_ip
}
