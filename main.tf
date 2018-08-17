//--------------------------------------------------------------------
// Modules
module "network" {
  source  = "app.terraform.io/iaac-anz-private/network/aws"
  version = "0.1.0"

  aws_access_key = "${var.aws_access_key}"
  aws_secret_key = "${var.aws_secret_key}"
  cidr = ["10.0.0.0/16"]
  create_vpc = "true"
  cross_zone_load_balancing = "true"
  enable_dhcp_options = "true"
  env = "PoC"
  private-app-subnet = "10.0.3.0/24"
  private-db-subnet = "10.0.4.0/24"
  public-frontend-subnet-primary = "10.0.1.0/24"
  public-frontend-subnet-secondary = "10.0.2.0/24"
  region = "${var.region}"
}