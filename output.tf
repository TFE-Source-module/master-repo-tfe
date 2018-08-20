output "vpcid" {
    value = "${module.corevpc.vpcid}"
    
}

output "vpcarn" {
    value = "${module.corevpc.vpcarn}"
   
}

/*output "vpcname" {
    value = "${module.corevpc.vpcname}"
    
}*/

output "vpc-cidr" {
    value = "${module.corevpc.vpc-cidr}"
    
}

output "main-rt" {
    value = "${module.corevpc.main-rt}"
    
}

output "default-nacl" {
    value = "${module.corevpc.default-nacl}"
    
}

output "default-sg" {
    value = "${module.corevpc.default-sg}"
    
}

output "default-rt" {
    value = "${module.corevpc.default-rt}"
}

output "az" {
    value = "${data.aws_availability_zones.available.names}"
}

output "public-subnet" {
    value = "${module.public-subnet.subnetid}"
}

output "private-subnets" {
    value = "${module.private-subnets.subnetid}"
}