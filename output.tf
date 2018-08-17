output "vpcid" {
    value = "${module.vpc.vpcid}"
    default = []
}

output "vpcarn" {
    value = "${module.vpc.vpcarn}"
    default = []
}

output "vpcname" {
    value = "${module.vpc.vpcname}"
    default = []
}

output "vpc-cidr" {
    value = "${module.vpc.vpc-cidr}"
    default = []
}

output "main-rt" {
    value = "${module.vpc.main-rt}"
    default = []
}

output "default-nacl" {
    value = "${module.vpc.default-nacl}"
    default = []
}

output "default-sg" {
    value = "${module.vpc.default-sg}"
    default = []
}

output "default-rt" {
    value = "${module.vpc.default-rt}"
}