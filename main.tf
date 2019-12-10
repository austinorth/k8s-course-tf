# Creates two Ubuntu servers to practice Kubernetes on.
# You will want to create a secrets.auto.tfvars file with the
# values that correspond to the following variables. See the
# secrets.auto.example file in the repo.
variable "cidr_blocks" {
  type    = "list"
  default = ["0.0.0.0/0"]
}

variable "public_key" {}
variable "region" {}
variable "subnet_id" {}
variable "username" {}
variable "vpc_id" {}

# Set AWS as provider and select regions specified in variable
provider "aws" {
  region = "${var.region}"
}

# Find the latest Ubuntu 18.04 Bionic AMI
data "aws_ami" "ubuntu" {
  most_recent = true

  filter {
    name   = "name"
    values = ["ubuntu/images/hvm-ssd/ubuntu-bionic-18.04-amd64-server-*"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }

  owners = ["099720109477"]
}

# Create a security group that allows ingress and egress on cidrs
# specified by user.
resource "aws_security_group" "k8s_practice" {
  name        = "k8s_practice_${var.username}"
  description = "All permissions needed for k8s for devs course."
  vpc_id      = "${var.vpc_id}"

  ingress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = "${var.cidr_blocks}"
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = "${var.cidr_blocks}"
  }
}

# Create a key pair with which to ssh into the instance
resource "aws_key_pair" "k8s_dev_key" {
  key_name   = "k8s_dev_key_${var.username}"
  public_key = "${var.public_key}"
}

# Create an EC2 instance for the master
resource "aws_instance" "k8s_master" {
  ami                    = "${data.aws_ami.ubuntu.id}"
  instance_type          = "m5.large"
  key_name               = "${aws_key_pair.k8s_dev_key.key_name}"
  vpc_security_group_ids = ["${aws_security_group.k8s_practice.id}"]
  subnet_id              = "${var.subnet_id}"

  tags = {
    Name = "k8s-dev-master-${var.username}"
  }
}

# Create an EC2 instance for the minion node
resource "aws_instance" "k8s_node" {
  ami                    = "${data.aws_ami.ubuntu.id}"
  instance_type          = "m5.large"
  key_name               = "${aws_key_pair.k8s_dev_key.key_name}"
  vpc_security_group_ids = ["${aws_security_group.k8s_practice.id}"]
  subnet_id              = "${var.subnet_id}"

  tags = {
    Name = "k8s-dev-node-${var.username}"
  }
}

output "master_ip" {
  value = "${aws_instance.k8s_master.private_ip}"
}

output "node_ip" {
  value = "${aws_instance.k8s_node.private_ip}"
}
