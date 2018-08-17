// Variables declaration
variable "aws_access_key" {}
variable "aws_secret_key" {}
variable "region" {}
variable "create_vpc" {}
//--------------------------------------------------------------------
// Data sources
data "aws_availability_zones" "available" {}

//--------------------------------------------------------------------
// Provider information
provider "aws" {
  access_key = "${var.aws_access_key}"
  secret_key = "${var.aws_secret_key}"
  region     = "${var.region}"
}
//--------------------------------------------------------------------
// Modules
//--------------------------------------------------------------------
// Modules
module "corevpc" {
  source  = "app.terraform.io/iaac-anz-private/vpc/aws"
  version = "0.1.4"

  cidr_block = ["10.0.0.0/16"]
  create_vpc = "${var.create_vpc}"
  env = "PoC"
  vpc_name = "Core-Network-VPC"
  
}

module "private-subnets" {
  source  = "app.terraform.io/iaac-anz-private/subnet/aws"
  version = "0.1.2"
  subnet_count = 2
  subnet_name = "private-subnet"
  vpc_id = "${module.corevpc.vpcid}"
  subnet_cidr_block = "10.0.2.0/24", "10.0.3.0/24"
  availability_zone = "${data.aws_availability_zones.available.*.names}"
  create_vpc = "${var.create_vpc}"
  env = "PoC"
}
