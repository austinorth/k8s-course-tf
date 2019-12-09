# Creates two Ubuntu servers to practice Kubernetes on.

variable "cidr_blocks" {
  type    = "list"
  default = ["0.0.0.0/0"]
}

variable "region" {}
variable "subnet_id" {}
variable "vpc_id" {}

provider "aws" {
  region = "${var.region}"
}

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

resource "aws_security_group" "k8s_practice" {
  name        = "k8s_practice"
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

resource "aws_instance" "k8s_master" {
  ami             = "${data.aws_ami.ubuntu.id}"
  instance_type   = "m5.large"
  security_groups = ["${aws_security_group.k8s_practice.id}"]
  subnet_id       = "${var.subnet_id}"
}

resource "aws_instance" "k8s_node" {
  ami             = "${data.aws_ami.ubuntu.id}"
  instance_type   = "m5.large"
  security_groups = ["${aws_security_group.k8s_practice.id}"]
  subnet_id       = "${var.subnet_id}"
}
