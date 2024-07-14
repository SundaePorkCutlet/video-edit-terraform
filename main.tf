provider "aws" {
  region = "ap-northeast-2"
}

module "vpc" {
  source     = "./modules/vpc"
  cidr_block = "10.1.0.0/16"
  name       = "my-vpc"
}

module "public_subnet_a" {
  source            = "./modules/subnet"
  vpc_id            = module.vpc.vpc_id
  cidr_block        = "10.1.1.0/26"
  availability_zone = "ap-northeast-2a"
  name              = "my-public-subnet-a"
}

module "private_subnet_app_a" {
  source            = "./modules/subnet"
  vpc_id            = module.vpc.vpc_id
  cidr_block        = "10.1.1.128/27"
  availability_zone = "ap-northeast-2a"
  name              = "my-private-subnet-app-a"
}

module "jenkins_sg" {
  source             = "./modules/security-group"
  vpc_id             = module.vpc.vpc_id
  ingress_from_port  = 8080
  ingress_to_port    = 8080
  ingress_protocol   = "tcp"
  ingress_cidr_blocks = ["0.0.0.0/0"]
  name               = "jenkins-sg"
}

module "jenkins_instance" {
  source              = "./modules/ec2"
  ami                 = "ami-01ed8ade75d4eee2f" # Ubuntu 22.04 LTS AMI ID
  instance_type       = "t2.micro"
  subnet_id           = module.private_subnet_app_a.subnet_id
  security_group_ids  = [module.jenkins_sg.security_group_id]
  key_name            = var.my_key_name
  name                = "jenkins"
}

module "ecr_backend" {
  source = "./modules/ecr"
  name   = "my-ecr-backend"
}

output "jenkins_private_ip" {
  value = module.jenkins_instance.private_ip
}

output "ecr_backend_repository_url" {
  value = module.ecr_backend.repository_url
}
