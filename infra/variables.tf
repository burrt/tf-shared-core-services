##############################
# Variables - use '_'
##############################

variable "my_local_ip" {
  description = "My local IP address stored as an environment variable"
  type        = string
}

variable "main_vpc_cidr" {
  description   = "Main VPC CIDR block"
  type          = string
  default       = "10.0.0.0/16"
}

variable "subnet_public_1_id" {
  description = "Public subnet 1"
  type        = string
  default     = ""
}
variable "subnet_public_2_id" {
  description = "Public subnet 2"
  type        = string
  default     = ""
}
variable "subnet_private_1_id" {
  description = "Private subnet 1"
  type        = string
  default     = ""
}
variable "subnet_private_2_id" {
  description = "Private subnet 2"
  type        = string
  default     = ""
}

variable "sec-group-ec2_jump_box" {
  description = "The ID of the EC2 Jump Box Security Group"
  type          = string
  default       = ""
}
variable "sec-group-lambda-dotnet-web-api" {
  description = "The ID of the .NET Web API Lambda Security Group"
  type          = string
  default       = ""
}
