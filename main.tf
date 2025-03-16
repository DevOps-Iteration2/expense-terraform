module "frontend" {
  depends_on     = [module.backend]

  source                  = "./modules/app"
  env                     = var.env
  instance_type           = var.instance_type
  zone_id                 = var.zone_id
  component               = "frontend"
  vault_token             = var.vault_token
  subnets                 = module.vpc.frontend_subnets
  vpc_id                  = module.vpc.vpc_id
  lb_type                 = "public"
  lb_needed               = true
  app_port                = 80
  lb_subnets              = module.vpc.public_subnets
  bastion_nodes           = var.bastion_nodes
  prometheus_nodes        = var.prometheus_nodes
  server_app_port_sg_cidr = var.public_subnets
  lb_app_port_sg_cidr     = ["0.0.0.0/0"]
  certificate_arn         = var.certificate_arn
  lb_ports                = { http : 80, https : 443 }
}

module "backend" {
  depends_on     = [module.mysql]

  source                  = "./modules/app"
  env                     = var.env
  instance_type           = var.instance_type
  zone_id                 = var.zone_id
  component               = "backend"
  vault_token             = var.vault_token
  subnets                 = module.vpc.backend_subnets
  vpc_id                  = module.vpc.vpc_id
  lb_type                 = "internal"
  lb_needed               = true
  app_port                = 8080
  lb_subnets              = module.vpc.backend_subnets
  bastion_nodes           = var.bastion_nodes
  prometheus_nodes        = var.prometheus_nodes
  server_app_port_sg_cidr = concat(var.frontend_subnets,var.backend_subnets)
  lb_app_port_sg_cidr     = var.frontend_subnets
  certificate_arn         = var.certificate_arn
  lb_ports                = { http : 8080 }
}

module "mysql" {
  source         = "./modules/app"

  env                     = var.env
  component               = "mysql"
  instance_type           = var.instance_type
  zone_id                 = var.zone_id
  vault_token             = var.vault_token
  subnets                 = module.vpc.db_subnets
  vpc_id                  = module.vpc.vpc_id
  app_port                = 3306
  bastion_nodes           = var.bastion_nodes
  prometheus_nodes        = var.prometheus_nodes
  server_app_port_sg_cidr = var.backend_subnets
}

module "vpc" {
  source = "./modules/vpc"

  env                     = var.env
  vpc_cidr_block          = var.vpc_cidr_block
 #subnet_cidr_block       = var.subnet_cidr_block
  default_vpc_id          = var.default_vpc_id
  default_vpc_cidr        = var.default_vpc_cidr
  default_route_table_id  = var.default_route_table_id
  frontend_subnets        = var.frontend_subnets
  backend_subnets         = var.backend_subnets
  db_subnets              = var.db_subnets
  availability_zones      = var.availability_zones
  public_subnets          = var.public_subnets
}