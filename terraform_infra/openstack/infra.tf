#VARIABLES
variable "user_name" {}
variable "password" {}
variable "private_key_path" {}
variable "key_name" {
  default = "dev_uex_otv_ciaas_ssh_key"
}
variable "security_group" {
  default = "dev_uex_otv_ciaas_sg"
}
variable "network" {
  default = "dev_uex_otv_ciaas_network"
}

# PROVIDERS
provider "openstack" {
  tenant_id   = "101a03d95ad6465d845294bc9926f2cc"
  user_name   = "admin"
  password    = "pwd"
  auth_url    = "https://cloud.eu-zrh.hub.kudelski.com:5000/v3"
  region      = "RegionOne"
}


#RESOURCES
resource "openstack_compute_instance_v2" "kube-node" {
  ami           = "f2b673cf-adf6-4ed6-a656-023787e08711"
  count         = 1
  instance_type = "c4.large"
  key_name      = "${var.key_name}"
}


# OUTPUT
#output "aws_instance_public_dns" {
#  value = "${aws_instance.nginx.public_dns}"
#}