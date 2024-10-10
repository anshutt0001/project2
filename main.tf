resource "aws_vpc" "Demo_vpc" {
  cidr_block = var.production
  tags = {
    Name = "Demo_vpc1"
  }
}
#creation of Public subnet1
resource "aws_subnet" "Public_subnet1" {
  vpc_id            = aws_vpc.Demo_vpc.id
  cidr_block        = var.public_subnet1
  availability_zone = var.availability_zone_public_subnet1
  tags = {
    Name = "Public_subnet1"
  }
}

#create internet_gateway
resource "aws_internet_gateway" "Demo_ig" {
  vpc_id = aws_vpc.Demo_vpc.id
  tags = {
    Name = "Demo_ig"
  }
}
#create first route tableroute-table Public_rt1
resource "aws_route_table" "Public_rt1" {
  vpc_id = aws_vpc.Demo_vpc.id
  tags = {
    Name = "Public_rt1"
  }
}

#subnet assocation with route table with Public_subnet1
resource "aws_route_table_association" "Public_rt1" {
  subnet_id      = aws_subnet.Public_subnet1.id
  route_table_id = aws_route_table.Public_rt1.id
}


# connect route_table1 with internet_gateway
resource "aws_route" "example" {
  route_table_id         = aws_route_table.Public_rt1.id
  destination_cidr_block = var.route_table1_with_internet_gateway
  gateway_id             = aws_internet_gateway.Demo_ig.id
  # in this block instead of example you can write anyhting
}

# create my security group
resource "aws_security_group" "my-sec-group" {
  name        = "my-sec-group"
  description = "Allow TLS inbound traffic"
  vpc_id      = aws_vpc.Demo_vpc.id
  ingress {
    description = "TLS from VPC"
    from_port   = var.inbound_to_HTTP
    to_port     = var.inbound_to_HTTP
    protocol    = "tcp"
  }
  egress {
    from_port = var.egress_from_port
    to_port   = var.egress_to_port
    protocol  = "-1"
  }
  tags = {
    Name = "my-sec-group"
  }
}
# update security group for ssh
resource "aws_security_group_rule" "inbound" {
  type              = "ingress"
  from_port         = var.inbound_for_ssh_from_port
  to_port           = var.inbound_for_ssh_to_port
  protocol          = "tcp"
  cidr_blocks       = var.incoming_traffic
  security_group_id = aws_security_group.my-sec-group.id
}
# resource "aws_security_group_rule" "outbound" {
#   type              = "egress"
#   from_port         = 0
#   to_port           = 0
#   protocol          = "-1"
#   cidr_blocks       = ["0.0.0.0/0"]
#   security_group_id = aws_security_group.my-sec-group.id
# }
#update security group for HTTP

resource "aws_security_group_rule" "inbound_for_HTTP" {
  type              = "ingress"
  from_port         = var.inbound_for_HTTP
  to_port           = var.inbound_to_HTTP
  protocol          = "tcp"
  cidr_blocks       = ["0.0.0.0/0"]
  security_group_id = aws_security_group.my-sec-group.id
}
resource "aws_security_group_rule" "outbound_for_HTTP" {
  type              = "egress"
  from_port         = 0
  to_port           = 0
  protocol          = "-1"
  cidr_blocks       = ["0.0.0.0/0"]
  security_group_id = aws_security_group.my-sec-group.id
}
# #create an Public_server1 instance
resource "aws_instance" "Public_server1" {
  ami                         = var.ami_of_Public_server1
  instance_type               = var.instance_type
  subnet_id                   = aws_subnet.Public_subnet1.id
  associate_public_ip_address = var.associate_public_ip_address
  vpc_security_group_ids      = [aws_security_group.my-sec-group.id] #["sg-017ebbacd07580994"]
  key_name                    = var.server1_key_name
  user_data                   = <<-USERDATA
    #!/bin/bash
    apt-get update
    apt-get install -y nginx
    service nginx start
  USERDATA
  tags = {
    Name = var.name_of_first_server
  }
}
# create a key pair using terraform 
resource "aws_key_pair" "tf-key-pair" {
  key_name   = var.server1_key_name
  public_key = tls_private_key.rsa.public_key_openssh
}
resource "tls_private_key" "rsa" {
  algorithm = "RSA"
  rsa_bits  = 4096
}
resource "local_file" "aws_keys" {
  content  = tls_private_key.rsa.private_key_pem
  filename = "ansul_keys"
}

# Create an AMI from the existing instance
resource "aws_ami_from_instance" "server1_ami" {
  name               = "server1_ami"
  source_instance_id = aws_instance.Public_server1.id
}

# Create a Launch Template
resource "aws_launch_template" "as_conf" {
  name_prefix   = "launch_template"
  image_id      = aws_ami_from_instance.server1_ami.id
  instance_type = "t2.micro"

  # Remove top-level vpc_security_group_ids
  # vpc_security_group_ids = [aws_security_group.my-sec-group.id]

  # Define network interface with security groups included
  network_interfaces {
    associate_public_ip_address = true
    security_groups             = [aws_security_group.my-sec-group.id]
  }

  # Use base64encode function to encode the user data
  user_data = base64encode(<<-USERDATA
    #!/bin/bash
    apt-get update
    apt-get install -y nginx
    service nginx start
  USERDATA
  )
}

# Create an Auto Scaling Group using the Launch Template
resource "aws_autoscaling_group" "asg" {
  name                      = "AutoScalingGroup"
  max_size                  = 5
  min_size                  = 1
  health_check_grace_period = 30
  health_check_type         = "ELB"
  desired_capacity          = 1
  force_delete              = true
  launch_template {
    id      = aws_launch_template.as_conf.id
    version = "$Latest"
  }
  vpc_zone_identifier       = [aws_subnet.Public_subnet1.id]
}

# Create a Target Tracking Scaling Policy for the Auto Scaling Group
resource "aws_autoscaling_policy" "example" {
  name                   = "target-scaling-policy"
  policy_type            = "TargetTrackingScaling"
  autoscaling_group_name = aws_autoscaling_group.asg.name
  target_tracking_configuration {
    predefined_metric_specification {
      predefined_metric_type = "ASGAverageCPUUtilization"
    }
    target_value = 25 # Adjust this value according to your needs
  }
}
