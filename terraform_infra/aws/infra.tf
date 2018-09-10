#VARIABLES
variable "aws_access_key" {}
variable "aws_secret_key" {}
variable "private_key_path" {}
variable "key_name" {
  default = "aws-delengg-key"
}


# PROVIDERS
provider "aws" {
  access_key = "${var.aws_access_key}"
  secret_key = "${var.aws_secret_key}"
  region     = "us-east-1"
}


#RESOURCES
resource "aws_instance" "kube-node" {
  ami           = "ami-04169656fea786776"
  count = 1
  instance_type = "t2.micro"
  key_name        = "${var.key_name}"
}


# OUTPUT
#output "aws_instance_public_dns" {
#  value = "${aws_instance.nginx.public_dns}"
#}