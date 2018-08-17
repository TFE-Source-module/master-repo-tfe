output "vpcid" {
    value = "${module.vpc.vpcid}"
    
}

output "vpcarn" {
    value = "${module.vpc.vpcarn}"
   
}

/*output "vpcname" {
    value = "${module.vpc.vpcname}"
    
}*/

output "vpc-cidr" {
    value = "${module.vpc.vpc-cidr}"
    
}

output "main-rt" {
    value = "${module.vpc.main-rt}"
    
}

output "default-nacl" {
    value = "${module.vpc.default-nacl}"
    
}

output "default-sg" {
    value = "${module.vpc.default-sg}"
    
}

output "default-rt" {
    value = "${module.vpc.default-rt}"
}