variable "aws_vpc_CIDR" {
  type    = string
  default = "10.0.0.0/16"
}
variable "production" {
  type    = string
  default = "170.0.0.0/16"
}

variable "public_subnet1" {
  type    = string
  default = "13.0.1.0/24"
}
variable "availability_zone_public_subnet1" {
  type    = string
  default = "us-east-1"

}

variable "route_table1_with_internet_gateway" {
  type    = string
  default = "10.0.0.0/16"
}
variable "ami_of_Public_server1" {
  type    = string
  default = "ami-037d9d63eb192f6cc"
}
variable "instance_type" {
  type    = string
  default = "t2.medium"
}
variable "associate_public_ip_address" {
  type    = string
  default = "false"
}
variable "name_of_first_server" {
  type    = string
  default = "server1"
}
variable "security_group_for_ssh" {
  type    = string
  default = "22"
}
variable "protocol" {
  type    = string
  default = "tcp"
}
variable "incoming_traffic" {
  type    = list(any)
  default = ["0.0.0.0/0"]
}
variable "security_group_for_HTTP" {
  type    = string
  default = "443"
}
variable "server1_key_name" {
  type    = string
  default = "aws_keys"
}
variable "security_grp_id" {
  type    = string
  default = "sg-05981ff20a1baadff"
}
variable "egress_from_port" {
  type = string

}
variable "egress_to_port" {
  type = string
}
variable "inbound_for_ssh_from_port" {
  type = string

}
variable "inbound_for_ssh_to_port" {
  type = string
}
variable "inbound_for_HTTP" {
  type = string

}
variable "inbound_to_HTTP" {
  type = string
}