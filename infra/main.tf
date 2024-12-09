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
  source = "github.com/burrt/AwsLambdaDotnetWebApi"
}

provider "aws" {
  region = "ap-southeast-2"
}

##############################
# Redis
##############################

resource "aws_elasticache_subnet_group" "shared-redis-cache-subnet-group" {
  name        = "shared-redis-cache-subnet-group"
  description = "Redis Cache Subnet Group"
  subnet_ids  = [
    aws_subnet.main-subnet-private1.id,
    aws_subnet.main-subnet-private2.id
  ]
}

resource "aws_elasticache_replication_group" "shared-redis-cluster-group" {
  replication_group_id        = "shared-redis-cluster-group"
  description                 = "Redis cluster for high availability"
  engine                      = "redis"
  engine_version              = "7.1"
  node_type                   = "cache.t2.micro"
  parameter_group_name        = "default.redis7"
  cluster_mode                = "disabled"
  transit_encryption_mode     = "required"
  num_cache_clusters          = 3
  port                        = 6379
  automatic_failover_enabled  = true
  multi_az_enabled            = true
  auto_minor_version_upgrade  = true
  at_rest_encryption_enabled  = true
  transit_encryption_enabled  = true
  security_group_ids          = [aws_security_group.elasticache-redis-traffic-sg.id]
  subnet_group_name           = aws_elasticache_subnet_group.shared-redis-cache-subnet-group.name
}
