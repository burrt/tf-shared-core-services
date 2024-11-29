##############################
# Output variables
##############################

output "vpc_id" {
  description = "The ID of the created VPC"
  value       = aws_vpc.main_vpc.id
}

output "subnet_public_1_id" {
  description = "The ID of the public 1 subnet"
  value       = aws_subnet.main_subnet_public1.id
}
output "subnet_public_2_id" {
  description = "The ID of the public 2 subnet"
  value       = aws_subnet.main_subnet_public2.id
}
output "subnet_private_1_id" {
  description = "The ID of the private 1 subnet"
  value       = aws_subnet.main_subnet_private1.id
}
output "subnet_private_2_id" {
  description = "The ID of the private 2 subnet"
  value       = aws_subnet.main_subnet_private2.id
}

output "ec2_jump_box_sg_id" {
  description = "The ID of the EC2 Jump Box Security Group"
  value       = aws_security_group.ec2_jump_box_ssh_sg.id
}

##############################
# Resources
##############################

# VPC
resource "aws_vpc" "main_vpc" {
  cidr_block = "10.0.0.0/16"
  assign_generated_ipv6_cidr_block = true
  enable_dns_support = true
  enable_dns_hostnames = true
}

# Subnets
resource "aws_subnet" "main_subnet_public1" {
  vpc_id     = aws_vpc.main_vpc.id
  cidr_block = "10.0.1.0/24"
}
resource "aws_subnet" "main_subnet_public2" {
  vpc_id     = aws_vpc.main_vpc.id
  cidr_block = "10.0.2.0/24"
}
resource "aws_subnet" "main_subnet_private1" {
  vpc_id     = aws_vpc.main_vpc.id
  cidr_block = "10.0.10.0/24"
}
resource "aws_subnet" "main_subnet_private2" {
  vpc_id     = aws_vpc.main_vpc.id
  cidr_block = "10.0.11.0/24"
}

# Security Groups
resource "aws_security_group" "ec2_jump_box_ssh_sg" {
  name        = "ec2_jump_box_ssh_sg"
  description = "Allow SSH inbound traffic and all outbound traffic"
  vpc_id      = aws_vpc.main_vpc.id
  ingress {
    # security_group_id = aws_security_group.ec2_jump_box_ssh_sg.id
    cidr_blocks         = [aws_vpc.main_vpc.cidr_block]
    ipv6_cidr_blocks    = [aws_vpc.main_vpc.ipv6_cidr_block]
    protocol            = "tcp"
    from_port           = 22
    to_port             = 22
    # TODO: restrict to dev laptop
  }
  egress {
    # security_group_id = aws_security_group.ec2_jump_box_ssh_sg.id
    cidr_blocks         = ["0.0.0.0/0"]
    ipv6_cidr_blocks    = ["::/0"]
    protocol            = "-1" # semantically equivalent to all ports
    from_port           = 0
    to_port             = 0
  }
}

resource "aws_security_group" "elasticache_redis_traffic_sg" {
  name        = "elasticache_redis_traffic_sg"
  description = "Allow TCP 6379 inbound traffic and all outbound traffic"
  vpc_id      = aws_vpc.main_vpc.id
  ingress {
    security_groups = [aws_security_group.ec2_jump_box_ssh_sg.id]
    protocol            = "tcp"
    from_port           = 6379
    to_port             = 6379
  }
  egress {
    # security_group_id = aws_security_group.ec2_jump_box_ssh_sg.id
    cidr_blocks         = ["0.0.0.0/0"]
    ipv6_cidr_blocks    = ["::/0"]
    protocol            = "-1" # semantically equivalent to all ports
    from_port           = 0
    to_port             = 0
  }
}
