#VARIABLES
variable "aws_access_key" {}
variable "aws_secret_key" {}
variable "private_key_path" {}
variable "key_name" {
  default = "aws-jenkins"
}
variable "aws_region" {
  description = "Region for the VPC"
  default = "us-east-2"
}

variable "aws_az" {
  description = "Availability zone for subnet"
  default = "us-east-2a"
}

variable "vpc_cidr" {
  description = "CIDR for the VPC"
  default = "10.0.0.0/16"
}

variable "public_subnet_cidr" {
  description = "CIDR for the public subnet"
  default = "10.0.1.0/24"
}

variable "private_subnet_cidr" {
  description = "CIDR for the private subnet"
  default = "10.0.2.0/24"
}

variable "ami" {
  description = "Ubuntu"
  default = "ami-0552e3455b9bc8d50"

}


# PROVIDERS
provider "aws" {
  access_key = "${var.aws_access_key}"
  secret_key = "${var.aws_secret_key}"
  region     = "${var.aws_region}"
}


#RESOURCES
# Define our VPC
resource "aws_vpc" "cluster-vpc" {
  cidr_block = "${var.vpc_cidr}"
  enable_dns_hostnames = true

  tags {
    Name = "Cluster VPC"
  }
}

# Define public subnet.
resource "aws_subnet" "public-subnet" {
  vpc_id = "${aws_vpc.cluster-vpc.id}"
  cidr_block = "${var.public_subnet_cidr}"
  availability_zone = "${var.aws_az}"

  tags {
    Name = "Cluster Subnet"
  }
}

# Define the internet gateway
resource "aws_internet_gateway" "gw" {
  vpc_id = "${aws_vpc.cluster-vpc.id}"

  tags {
    Name = "Cluster IGW"
  }
}

#Create Route from route table automatically created during i-g
resource "aws_route" "internet_access" {
  route_table_id         = "${aws_vpc.cluster-vpc.main_route_table_id}"

  destination_cidr_block = "0.0.0.0/0"
  gateway_id             = "${aws_internet_gateway.gw.id}"
}

/*
# Define the route table
resource "aws_route_table" "web-public-rt" {
  vpc_id = "${aws_vpc.cluster-vpc.id}"

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = "${aws_internet_gateway.gw.id}"
  }

  tags {
    Name = "Public Subnet RT"
  }
}
*/

# Assign the route table to the public Subnet
resource "aws_route_table_association" "web-public-rt" {
  subnet_id = "${aws_subnet.public-subnet.id}"
  route_table_id = "${aws_vpc.cluster-vpc.main_route_table_id}"
}

# Define the security group for public subnet
resource "aws_security_group" "sgweb" {
  name = "vpc_test_web"
  description = "Allow incoming HTTP connections & SSH access"

  ingress {
    from_port = 80
    to_port = 80
    protocol = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port = 443
    to_port = 443
    protocol = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port = -1
    to_port = -1
    protocol = "icmp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port = 22
    to_port = 22
    protocol = "tcp"
    cidr_blocks =  ["0.0.0.0/0"]
  }

  egress {
    from_port       = 0
    to_port         = 0
    protocol        = "-1"
    cidr_blocks     = ["0.0.0.0/0"]
  }

  vpc_id="${aws_vpc.cluster-vpc.id}"

  tags {
    Name = "Web Server SG"
  }
}

# Define master inside the public subnet
resource "aws_instance" "master" {
  ami  = "${var.ami}"
  instance_type = "t2.micro"
  key_name = "${var.key_name}"
  subnet_id = "${aws_subnet.public-subnet.id}"
  vpc_security_group_ids = ["${aws_security_group.sgweb.id}"]
  associate_public_ip_address = true
  source_dest_check = false

//  connection {
//    user        = "ubuntu"
//    private_key = "${file(var.private_key_path)}"
//  }

//  provisioner "remote-exec" {
//    inline = [
//      "sudo apt-get update",
//      "sudo apt-get upgrade -y",
//      "sudo apt-get install nginx -y",
//      "sudo service nginx start"
//    ]
//  }

  tags {
    Name = "kube-master"
  }
}


# Define kube node-1 inside the public subnet
resource "aws_instance" "node-1" {
  ami  = "${var.ami}"
  instance_type = "t2.micro"
  key_name = "${var.key_name}"
  subnet_id = "${aws_subnet.public-subnet.id}"
  vpc_security_group_ids = ["${aws_security_group.sgweb.id}"]
  associate_public_ip_address = true
  source_dest_check = false

  connection {
    user        = "ubuntu"
    private_key = "${file(var.private_key_path)}"
  }

  provisioner "remote-exec" {
    inline = [
      "sudo apt-get update",
      "sudo apt-get upgrade -y"
    ]
  }

  tags {
    Name = "kube-node-1"
  }
}

# Define kube-node-2 inside the public subnet
resource "aws_instance" "node-2" {
  ami  = "${var.ami}"
  instance_type = "t2.micro"
  key_name = "${var.key_name}"
  subnet_id = "${aws_subnet.public-subnet.id}"
  vpc_security_group_ids = ["${aws_security_group.sgweb.id}"]
  associate_public_ip_address = true
  source_dest_check = false

  connection {
    user        = "ubuntu"
    private_key = "${file(var.private_key_path)}"
  }

  provisioner "remote-exec" {
    inline = [
      "sudo apt-get update",
      "sudo apt-get upgrade -y"
    ]
  }

  tags {
    Name = "kube-node-2"
  }
}
/*
# Define utility-server inside the public subnet
resource "aws_instance" "util" {
  ami  = "${var.ami}"
  instance_type = "t2.micro"
  key_name = "${var.key_name}"
  subnet_id = "${aws_subnet.public-subnet.id}"
  vpc_security_group_ids = ["${aws_security_group.sgweb.id}"]
  associate_public_ip_address = true
  source_dest_check = false

  connection {
    user        = "ubuntu"
    private_key = "${file(var.private_key_path)}"
  }

  provisioner "remote-exec" {
    inline = [
      "sudo apt-get update",
      "sudo apt-get upgrade -y"
    ]
  }

  tags {
    Name = "util-server"
  }
}
*/

#OUTPUT
output "master_ip" {
  value = "${aws_instance.master.public_ip}"
}
output "node_1" {
  value = "${aws_instance.node-1.public_ip}"
}
output "node_2" {
  value = "${aws_instance.node-2.public_ip}"
}