locals {
  env = "dev"
}

provider "google" {
  project = "${var.project}"
}

module "vpc_network" {
  source  = "../../modules/vpc_network"
  project = "${var.project}"
  env     = "${local.env}"
}

module "http_server" {
  source  = "../../modules/http_server"
  project = "${var.project}"
  subnet  = "${module.vpc.subnet}"
}

module "firewall" {
  source  = "../../modules/firewall"
  project = "${var.project}"
  subnet  = "${module.vpc.subnet}"
}
