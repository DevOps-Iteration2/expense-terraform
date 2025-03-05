module "frontend" {
  depends_on     = [module.backend]

  source         = "./modules/app"
  env            = var.env
  instance_type  = var.instance_type
  zone_id        = var.zone_id
  component      = "frontend"
  vault_token    = var.vault_token
}

module "backend" {
  depends_on     = [module.mysql]

  source         = "./modules/app"
  env            = var.env
  instance_type  = var.instance_type
  zone_id        = var.zone_id
  component      = "backend"
  vault_token    = var.vault_token
}

module "mysql" {
  source         = "./modules/app"

  env            = var.env
  component      = "mysql"
  instance_type  = var.instance_type
  zone_id        = var.zone_id
  vault_token    = var.vault_token
}