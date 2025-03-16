variable "env" {}
variable "instance_type" {}
variable "zone_id" {}
variable "component" {}
variable "vault_token" {}
variable "subnets" {}
variable "vpc_id" {}
variable "lb_type" {
  default = null
}
variable "lb_needed" {
  default = false
}
variable "app_port" {
  default = null
}
variable "lb_subnets" {
  default = null
}

variable "bastion_nodes" {}
variable "prometheus_nodes" {}
variable "server_app_port_sg_cidr" {}
variable "lb_app_port_sg_cidr" {
  default = []
}
variable "certificate_arn" {
  default = null
}
variable "lb_ports" {
  default = {}
}