output "vpc_ka_output" {
  value = aws_vpc.Demo_vpc.id
}
output "id_of_public_subnet1" {
  value = aws_subnet.Public_subnet1.id
}

output "id_of_internet_gateway" {
  value = aws_internet_gateway.Demo_ig.id
}
output "id_of_route_table1" {
  value = aws_route_table.Public_rt1.id
}

output "id_of_server1" {
  value = aws_instance.Public_server1.id
}
output "id_of_my_security_group" {
  value = aws_security_group.my-sec-group.id
}
output "public_server1" {
  value = aws_instance.Public_server1.id
}

output "id_of_ami" {
  value = aws_ami_from_instance.server1_ami.id
}
output "autoscaling_group_name" {
  value = aws_autoscaling_group.asg.name

}

output "security_group_id_inbound" {
  value = aws_security_group.my-sec-group.id
}
output "security_group_id_outbound" {
  value = aws_security_group.my-sec-group.id
}