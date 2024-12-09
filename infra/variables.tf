##############################
# Variables - use '_'
##############################

variable "my_local_ip" {
  description   = "My local IP address stored as an environment variable"
  type          = string
}

variable "subnet_public_1_id" {
  description   = "Public subnet 1"
  type          = string
  default       = ""
}
variable "subnet_public_2_id" {
  description   = "Public subnet 2"
  type          = string
  default       = ""
}
variable "subnet_private_1_id" {
  description   = "Private subnet 1"
  type          = string
  default       = ""
}
variable "subnet_private_2_id" {
  description   = "Private subnet 2"
  type          = string
  default       = ""
}
