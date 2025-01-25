##############################
# Output variables
##############################

output "vpc_id" {
  description = "The ID of the created VPC"
  value       = aws_vpc.main-vpc.id
}

# Subnets
output "subnet_public_1_id" {
  description = "The ID of the public 1 subnet"
  value       = aws_subnet.main-subnet-public1.id
}
output "subnet_public_2_id" {
  description = "The ID of the public 2 subnet"
  value       = aws_subnet.main-subnet-public2.id
}
output "subnet_private_1_id" {
  description = "The ID of the private 1 subnet"
  value       = aws_subnet.main-subnet-private1.id
}
output "subnet_private_2_id" {
  description = "The ID of the private 2 subnet"
  value       = aws_subnet.main-subnet-private2.id
}

output "ec2_jump_box_sg_id" {
  description = "The ID of the EC2 Jump Box Security Group"
  value       = aws_security_group.ec2-jump-box-ssh-sg.id
}
