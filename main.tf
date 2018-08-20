// Variables declaration
variable "aws_access_key" {}
variable "aws_secret_key" {}
variable "region" {}
variable "create_vpc" {}
variable "enable_dhcp_options" {}

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
  version = "0.1.6"
  subnet_name = "private-subnet"
  vpc_id = "${module.corevpc.vpcid}"
  subnet_cidr_block = ["10.0.2.0/24", "10.0.3.0/24", "10.0.4.0/24", "10.0.5.0/24"]
  availability_zone = ["${data.aws_availability_zones.available.names[0]}", "${data.aws_availability_zones.available.names[1]}", "${data.aws_availability_zones.available.names[2]}"]
  create_vpc = "${var.create_vpc}"
  env = "PoC"
}

module "public-subnet" {
  source = "app.terraform.io/iaac-anz-private/subnet/aws"
  version = "0.1.6"
  subnet_name = "public-subnet"
  vpc_id = "${module.corevpc.vpcid}"
  subnet_cidr_block = ["10.0.6.0/24", "10.0.7.0/24"]
  availability_zone = ["${data.aws_availability_zones.available.names[0]}", "${data.aws_availability_zones.available.names[1]}", "${data.aws_availability_zones.available.names[2]}"]
  create_vpc = "${var.create_vpc}"
  env = "PoC"
}

module "core-network-dhcp" {
  # Configure DHCP Option set
  source              = "app.terraform.io/iaac-anz-private/dhcp/aws"
  version = "0.1.0"
  name                = "core-network-dhcp"
  vpc_id              = "${module.corevpc.vpcid}"
  domain_name = "poc.local"
  domain_name_servers = ["127.0.0.1", "10.0.0.2"]
  ntp_servers = ["127.0.0.1"]
  netbios_name_servers = ["127.0.0.1"]
  netbios_node_type = 2
  create_vpc          = "${var.create_vpc}"
  enable_dhcp_options = "${var.enable_dhcp_options}"
  env = "PoC"
}

module "public-route-table" {
  # Configure Public Route Table
  source     = "app.terraform.io/iaac-anz-private/routetable/aws"
  version = "0.1.0"
  name       = "core-network-frontend-routetable"
  vpc_id     = "${module.corevpc.vpcid}"
  subnets = ["10.0.6.0/24", "10.0.7.0/24"]
  env        = "PoC"
  type       = "public"                                    # public or private
  create_vpc = "${var.create_vpc}"
}

module "private-route-table" {
  # Configure Public Route Table
  source     = "app.terraform.io/iaac-anz-private/routetable/aws"
  version = "0.1.0"
  name       = "core-network-backend-routetable"
  vpc_id     = "${module.corevpc.vpcid}"
  subnets = ["10.0.2.0/24", "10.0.3.0/24", "10.0.4.0/24", "10.0.5.0/24"]
  env        = "PoC"
  type       = "private"                                    # public or private
  create_vpc = "${var.create_vpc}"
}

/*module "public-rt-association" {
  source     = "app.terraform.io/iaac-anz-private/routetableassociation/aws"
  version = "0.1.0"
  create_vpc = "${var.create_vpc}"
  subnet_id = "${module.public-subnet.subnetid}"
  route_table_id = "${module.public-route-table.rtid}"
}*/
