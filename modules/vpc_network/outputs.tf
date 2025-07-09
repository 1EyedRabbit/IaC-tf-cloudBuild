output "network" {
  value = "${module.vpc_network.network_name}"
}

output "subnet" {
  value = "${element(module.vpc_network.subnets_names, 0)}"
}
