#VARIABLES
variable "user_name" {}
variable "password" {}
variable "private_key_path" {}
variable "key_pair" {
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
  tenant_name = "uex-psd-dev"
  user_name   = "${var.user_name}"
  password    = "${var.password}"
  auth_url    = "https://cloud.eu-zrh.hub.kudelski.com:5000/v3"
  region      = "RegionOne"
  domain_name = "hq.k.grp"
}


#RESOURCES
resource "openstack_compute_instance_v2" "kube-node1" {
  name          = "kube-node1_tf"
  image_id      = "f2b673cf-adf6-4ed6-a656-023787e08711"
  count         = 1
  flavor_name   = "c4.large"
  key_pair      = "${var.key_pair}"
  security_groups = ["dev_uex_otv_ciaas_sg","default"]
  network {
    name = "${var.network}"
  }
}

resource "openstack_networking_floatingip_v2" "fip_1" {
  pool = "k.grp"
}

resource "openstack_compute_floatingip_associate_v2" "fip_1" {
  floating_ip = "${openstack_networking_floatingip_v2.fip_1.address}"
  instance_id = "${openstack_compute_instance_v2.kube-node1.id}"
}

resource "openstack_compute_instance_v2" "kube-node2" {
  name          = "kube-node2_tf"
  image_id      = "f2b673cf-adf6-4ed6-a656-023787e08711"
  count         = 1
  flavor_name   = "c4.large"
  key_pair      = "${var.key_pair}"
  security_groups = ["dev_uex_otv_ciaas_sg","default"]
  network {
    name = "${var.network}"
  }
}

resource "openstack_networking_floatingip_v2" "fip_2" {
  pool = "k.grp"
}

resource "openstack_compute_floatingip_associate_v2" "fip_2" {
  floating_ip = "${openstack_networking_floatingip_v2.fip_2.address}"
  instance_id = "${openstack_compute_instance_v2.kube-node2.id}"
}

resource "openstack_compute_instance_v2" "kube-master" {
  name          = "kube-master_tf"
  image_id      = "f2b673cf-adf6-4ed6-a656-023787e08711"
  count         = 1
  flavor_name   = "c4.large"
  key_pair      = "${var.key_pair}"
  security_groups = ["dev_uex_otv_ciaas_sg","default"]
  network {
    name = "${var.network}"
  }
}

resource "openstack_networking_floatingip_v2" "fip_3" {
  pool = "k.grp"
}

resource "openstack_compute_floatingip_associate_v2" "fip_3" {
  floating_ip = "${openstack_networking_floatingip_v2.fip_3.address}"
  instance_id = "${openstack_compute_instance_v2.kube-master.id}"
}
# OUTPUT
#output "aws_instance_public_dns" {
#  value = "${aws_instance.nginx.public_dns}"
#}