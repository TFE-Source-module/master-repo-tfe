//--------------------------------------------------------------------
// Modules
//--------------------------------------------------------------------
// Modules
module "vpc" {
  source  = "app.terraform.io/iaac-anz-private/vpc/aws"
  version = "0.1.1"

  cidr_block = ["10.0.0.0/16"]
  create_vpc = "true"
  env = "PoC"
  vpc_name = "Core-Network-VPC"
}