module "consul" {
  source = "github.com/burrt/AwsLambdaDotnetWebApi"
}

##############################
# Redis
##############################

resource "aws_elasticache_subnet_group" "shared-redis-cache-subnet-group" {
  name        = "shared-redis-cache-subnet-group"
  description = "Redis Cache Subnet Group"
  subnet_ids = [
    aws_subnet.main-subnet-private1.id,
    aws_subnet.main-subnet-private2.id
  ]
}

resource "aws_elasticache_user" "web-api-lambda-user" {
  user_id       = "web-api-lambda-user"
  user_name     = "web-api-lambda-user"
  access_string = "on ~* -@all +@connection +@fast +@slow +@scripting +@read +@write"
  engine        = "REDIS"
  passwords     = [var.lambda_dotnet_redis_user_password, var.lambda_dotnet_redis_user_password]
  authentication_mode {
    type = "password"
  }
}

resource "aws_elasticache_user" "restricted-default-user" {
  user_id              = "restricted-default-user"
  user_name            = "default"
  access_string        = "off ~* -@all"
  engine               = "REDIS"
  no_password_required = true
}

resource "aws_elasticache_user_group" "shared-redis-user-group" {
  engine        = "REDIS"
  user_group_id = "shared-redis-user-group-id"
  user_ids = [
    aws_elasticache_user.web-api-lambda-user.user_id,
    aws_elasticache_user.restricted-default-user.user_id
  ]
}

resource "aws_elasticache_replication_group" "shared-redis-cluster-group" {
  replication_group_id       = "shared-redis-cluster-group"
  description                = "Redis cluster for high availability"
  engine                     = "redis"
  engine_version             = "7.1"
  node_type                  = "cache.t2.micro"
  parameter_group_name       = "default.redis7"
  cluster_mode               = "disabled"
  transit_encryption_mode    = "required"
  num_cache_clusters         = 3
  port                       = 6379
  automatic_failover_enabled = true
  multi_az_enabled           = true
  auto_minor_version_upgrade = true
  at_rest_encryption_enabled = true
  transit_encryption_enabled = true
  subnet_group_name          = aws_elasticache_subnet_group.shared-redis-cache-subnet-group.name
  security_group_ids         = [aws_security_group.elasticache-redis-traffic-sg.id]
  user_group_ids             = [aws_elasticache_user_group.shared-redis-user-group.user_group_id]
}
