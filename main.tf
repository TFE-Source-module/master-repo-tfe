// Variables declaration
variable "aws_access_key" {}

variable "aws_secret_key" {}

variable "region" {}

variable "create_vpc" {}

variable "enable_dhcp_options" {}

variable "private-subnet-cidr_block" {
  default = ["10.0.2.0/24", "10.0.3.0/24", "10.0.4.0/24", "10.0.5.0/24"]
}

variable "public-subnet-cidr_block" {
  default = ["10.0.6.0/24", "10.0.7.0/24"]
}

variable "single_nat" {
  default = true
  description = "Set to 'true' for single NAT gateway for all private subnets. Defaults to true"
}

variable "db_user" {}

variable "db_pass" {}

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
  version = "0.1.7"
  subnet_name = "private-subnet"
  vpc_id = "${module.corevpc.vpcid}"
  subnet_cidr_block = "${var.private-subnet-cidr_block}"
  availability_zone = ["${data.aws_availability_zones.available.names[0]}", "${data.aws_availability_zones.available.names[1]}", "${data.aws_availability_zones.available.names[2]}"]
  create_vpc = "${var.create_vpc}"
  env = "PoC"
}

module "public-subnet" {
  source = "app.terraform.io/iaac-anz-private/subnet/aws"
  version = "0.1.7"
  subnet_name = "public-subnet"
  vpc_id = "${module.corevpc.vpcid}"
  subnet_cidr_block = "${var.public-subnet-cidr_block}"
  #availability_zone = ["${data.aws_availability_zones.available.names[0]}", "${data.aws_availability_zones.available.names[1]}", "${data.aws_availability_zones.available.names[2]}"]
  availability_zone = ["${data.aws_availability_zones.available.names}"]
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
  version = "0.1.1"
  name       = "core-network-frontend-routetable"
  vpc_id     = "${module.corevpc.vpcid}"
  subnets = "${var.public-subnet-cidr_block}"
  env        = "PoC"
  type       = "public"                                    # public or private
  create_vpc = "${var.create_vpc}"
}

module "private-route-table" {
  # Configure Public Route Table
  source     = "app.terraform.io/iaac-anz-private/routetable/aws"
  version = "0.1.2"
  name       = "core-network-backend-routetable"
  vpc_id     = "${module.corevpc.vpcid}"
  subnets = "${var.private-subnet-cidr_block}"
  subnet_id = "${module.public-subnet.subnetid}"
  env        = "PoC"
  type       = "private"                                    # public or private
  create_vpc = "${var.create_vpc}"
}

/*module "public-rt-association" {
  source     = "app.terraform.io/iaac-anz-private/routetableassociation/aws"
  version = "0.1.4"
  create_vpc = "${var.create_vpc}"
  subnet_id = "${module.public-subnet.subnetid}"
  route_table_id = "${module.public-route-table.rtid}"
}

module "private-rt-association" {
  source     = "app.terraform.io/iaac-anz-private/routetableassociation/aws"
  version = "0.1.4"
  create_vpc = "${var.create_vpc}"
  subnet_id = "${module.private-subnets.subnetid}"
  route_table_id = "${module.private-route-table.rtid}"
}*/

module "igw" {
  # Configure IGW
  source                 = "app.terraform.io/iaac-anz-private/igw/aws"
  version = "0.2.2"
  name = "Internet-gateway"
  vpc_id                 = "${module.corevpc.vpcid}"
  env                    = "PoC"
  igw_route              = true
  create_vpc             = "${var.create_vpc}"
  igw_route_count = "${length(var.public-subnet-cidr_block)}"
  route_table_id         = "${module.public-route-table.rtid}"
  destination_cidr_block = "0.0.0.0/0"
  tags = {
    env = "PoC"
    source = "TFE"
  }
}

module "ngweip" {
  source       = "app.terraform.io/iaac-anz-private/eip/aws"
  version = "0.1.3"
  create_vpc   = "${var.create_vpc}"
  count = "${var.single_nat ? 1 : length(var.private-subnet-cidr_block)}"
  eip          = true
  name = "NatGW-EIP"
  env          = "PoC"
  tags = {
    env = "PoC"
    source = "TFE"
  }
}

module "ngw" {
  source            = "app.terraform.io/iaac-anz-private/nat/aws"
  version = "0.2.2"
  nat_gateway_route = true
  env               = "PoC"
  name = "Natgateway"
  count = "${var.single_nat ? 1 : length(var.private-subnet-cidr_block)}"
  nat_routes = "${length(var.private-subnet-cidr_block)}"
  create_vpc        = "${var.create_vpc}"
  subnet_id         = "${module.public-subnet.subnetid}"
  allocation_id     = "${module.ngweip.eipalloc}"
  route_table_id         = "${module.private-route-table.rtid}"
  destination_cidr_block = "0.0.0.0/0"
  tags = {
    env = "PoC"
    source = "TFE"
  }
}

module "beanstalk-role" {
  source = "app.terraform.io/iaac-anz-private/managed-roles/aws"
  version = "0.1.0"
  role_name = "aws-elasticbeanstalk-service-role"
}

module "paas-elasticbeanstalk" {
  source = "app.terraform.io/iaac-anz-private/paas-eb/aws"
  version = "0.1.6"
  env = "PoC"
  appname = "sampleapp"
  create_vpc = "${var.create_vpc}"
  service_role = "${module.beanstalk-role.rolearn}"
  tier = "WebServer" # e.g. ('WebServer', 'Worker')
  #solution_stack_name = "64bit Amazon Linux 2018.03 v2.7.2 running Python 3.6"
  vpcid = "${module.corevpc.vpcid}"
  version_label = "sample-v0.1"
  /*updating_min_in_service = "1"
  updating_max_batch = "1"
  rolling_update_type = "Time"
  private_subnets = "${module.private-subnets.subnetid}"
  ssh_source_restriction = "0.0.0.0/0"
  root_volume_size = "15"
  root_volume_type = "gp2"
  ssh_listener_port = "22"
  environment_type = "LoadBalanced"
  lb_type = "classic"
  http_listener_enabled = true
  https_listener_enabled = false*/
  public_subnet = "${module.public-subnet.subnetid}"
}

module "db" {
  source = "app.terraform.io/iaac-anz-private/rds/aws"
  version = "0.2.0"
  storage_type = "gp2"
  allocated_storage = 5
  create_vpc = "${var.create_vpc}"
  create_rds = true
  engine               = "mysql"
  engine_version       = "5.7"
  instance_class       = "db.t2.micro"
  subnetgrp_create = true
  name_prefix = "db-subnetgrp"
  skip_final_snapshot = false
  identifier = "mysql"
  subnet_ids = "${module.private-subnets.subnetid}"
  publicly_accessible = false
  copy_tags_to_snapshot = true
  multi_az = true
  name     = "demodb"
  username = "${var.db_user}"
  password = "${var.db_pass}"
  port     = "3306"
  tags = {
    env = "PoC"
    source = "TFE"
  }
}