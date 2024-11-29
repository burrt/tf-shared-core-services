terraform {
  required_version = ">= 1.9.8"

  cloud {
    organization = "personal-burrt"
    workspaces {
      name = "shared-services"
    }
  }
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.76"
    }
  }
}

module "consul" {
  source = "git@github.com:burrt/AwsLambdaDotnetWebApi.git"
}

provider "aws" {
  region = "ap-southeast-2"
}

resource "aws_elasticache_subnet_group" "shared-redis-cache-subnet-group" {
  name        = "shared-redis-cache-subnet-group"
  description = "Redis Cache Subnet Group"
  subnet_ids = [
    var.subnet_public_1_id,
    var.subnet_private_2_id
  ]
}

resource "aws_elasticache_cluster" "shared-cache" {
  cluster_id            = "shared-cache-cluster"
  engine                = "redis"
  node_type             = "cache.t2.micro"
  parameter_group_name  = "default.redis7"
  num_cache_nodes       = 1
  port                  = 6379
  engine_version        = "7.1"
  subnet_group_name     = aws_elasticache_subnet_group.shared-redis-cache-subnet-group.name
  security_group_ids    = [aws_security_group.elasticache_redis_traffic_sg.id]
}

# create security group for the cluster (redis traffic)
# create security group for the ec2 (ssh traffic)
# allocate an elastic ip for public IP
