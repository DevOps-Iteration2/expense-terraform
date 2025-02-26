module "frontend" {
  source         = "./modules/app"
  env            = var.env
  instance_type  = var.instance_type
  zone_id        = var.zone_id
  component      = "frontend"
  ssh_user       = var.ssh_user
  ssh_pass       = var.ssh_pass
}

module "backend" {
  depends_on     = [module.mysql]

  source         = "./modules/app"
  env            = var.env
  instance_type  = var.instance_type
  zone_id        = var.zone_id
  component      = "backend"
  ssh_user       = var.ssh_user
  ssh_pass       = var.ssh_pass
}

module "mysql" {
  source         = "./modules/app"

  env            = var.env
  component      = "mysql"
  instance_type  = var.instance_type
  zone_id        = var.zone_id
  ssh_user       = var.ssh_user
  ssh_pass       = var.ssh_pass
}