# Route table for public traffic into EC2
resource "aws_internet_gateway" "public-gateway" {
  vpc_id = aws_vpc.main-vpc.id
}

resource "aws_route_table" "public-routes" {
  vpc_id = aws_vpc.main-vpc.id
  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.public-gateway.id
  }
}

resource "aws_route_table_association" "public-route-subnet-1" {
  route_table_id = aws_route_table.public-routes.id
  subnet_id      = aws_subnet.main-subnet-public1.id
}
resource "aws_route_table_association" "public-route-subnet-2" {
  route_table_id = aws_route_table.public-routes.id
  subnet_id      = aws_subnet.main-subnet-public2.id
}

##############################
# Resources
##############################

# VPC
resource "aws_vpc" "main-vpc" {
  cidr_block                       = var.main_vpc_cidr
  assign_generated_ipv6_cidr_block = true
  enable_dns_support               = true
  enable_dns_hostnames             = true
}

# VPC Endpoint
resource "aws_vpc_endpoint" "secrets-manager-vpc-endpoint" {
  vpc_id              = aws_vpc.main-vpc.id
  service_name        = "com.amazonaws.ap-southeast-2.secretsmanager"
  vpc_endpoint_type   = "Interface"
  private_dns_enabled = true
  subnet_ids          = [aws_subnet.main-subnet-private1.id, aws_subnet.main-subnet-private2.id]
  security_group_ids  = [aws_security_group.lambda-dotnet-web-api-sg.id]
}

# Subnets
resource "aws_subnet" "main-subnet-public1" {
  vpc_id            = aws_vpc.main-vpc.id
  cidr_block        = "10.0.1.0/24"
  availability_zone = "ap-southeast-2a"
}
resource "aws_subnet" "main-subnet-public2" {
  vpc_id            = aws_vpc.main-vpc.id
  cidr_block        = "10.0.2.0/24"
  availability_zone = "ap-southeast-2b"
}
resource "aws_subnet" "main-subnet-private1" {
  vpc_id            = aws_vpc.main-vpc.id
  cidr_block        = "10.0.10.0/24"
  availability_zone = "ap-southeast-2a"
}
resource "aws_subnet" "main-subnet-private2" {
  vpc_id            = aws_vpc.main-vpc.id
  cidr_block        = "10.0.11.0/24"
  availability_zone = "ap-southeast-2b"
}

# Security Groups
resource "aws_security_group" "ec2-jump-box-ssh-sg" {
  name        = "ec2-jump-box-ssh-sg"
  description = "Allow SSH inbound traffic and all outbound traffic"
  vpc_id      = aws_vpc.main-vpc.id
  ingress {
    cidr_blocks = [var.my_local_ip]
    protocol    = "tcp"
    from_port   = 22
    to_port     = 22
  }
  egress {
    cidr_blocks      = ["0.0.0.0/0"]
    ipv6_cidr_blocks = ["::/0"]
    protocol         = "-1" # semantically equivalent to all ports
    from_port        = 0
    to_port          = 0
  }
}

resource "aws_security_group" "lambda-dotnet-web-api-sg" {
  name        = "lambda-dotnet-web-api-sg"
  description = "Allow HTTPS inbound traffic and all outbound traffic"
  vpc_id      = aws_vpc.main-vpc.id
  ingress {
    cidr_blocks = [var.main_vpc_cidr]
    protocol    = "tcp"
    from_port   = 443
    to_port     = 443
  }
  egress {
    cidr_blocks      = ["0.0.0.0/0"]
    ipv6_cidr_blocks = ["::/0"]
    protocol         = "-1" # semantically equivalent to all ports
    from_port        = 0
    to_port          = 0
  }
}

resource "aws_security_group" "elasticache-redis-traffic-sg" {
  name        = "elasticache-redis-traffic-sg"
  description = "Allow TCP 6379 inbound traffic and all outbound traffic"
  vpc_id      = aws_vpc.main-vpc.id
  ingress {
    protocol        = "tcp"
    from_port       = 6379
    to_port         = 6379
    security_groups = [aws_security_group.lambda-dotnet-web-api-sg.id]
  }
  egress {
    cidr_blocks      = ["0.0.0.0/0"]
    ipv6_cidr_blocks = ["::/0"]
    protocol         = "-1" # semantically equivalent to all ports
    from_port        = 0
    to_port          = 0
  }
}
