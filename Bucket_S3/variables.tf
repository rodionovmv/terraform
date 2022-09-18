variable "region" {
  type = string
  default = "us-west-2"
}

#variable "bucket_prefix" {
#  type = string
#  default = "tf-bucket"
#}

variable "subnet_id" {
  type = string
  default = "my_subnet"
}
variable "my_vpc" {
  type = string
  default = "vpc.id"
}