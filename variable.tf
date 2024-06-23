variable "my_ip" {
  description = "Your IP address with CIDR suffix"
  type        = string
}

variable "my_key_name" {
  description = "Name of the key pair to use for the EC2 instance"
  type        = string
}