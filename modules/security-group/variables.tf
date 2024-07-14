variable "vpc_id" {
  description = "The VPC ID"
  type        = string
}

variable "ingress_from_port" {
  description = "Ingress from port"
  type        = number
}

variable "ingress_to_port" {
  description = "Ingress to port"
  type        = number
}

variable "ingress_protocol" {
  description = "Ingress protocol"
  type        = string
}

variable "ingress_cidr_blocks" {
  description = "Ingress CIDR blocks"
  type        = list(string)
}

variable "name" {
  description = "Name tag for the security group"
  type        = string
}
