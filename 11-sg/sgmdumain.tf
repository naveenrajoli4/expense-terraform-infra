
module "sg_mysql" {
  source        = "git::https://github.com/naveenrajoli4/ter-sg-module-dev.git?ref=main"
  sg_name       = "mysql"
  description   = "Created for MySQL instances in expense prod"
  location      = var.location
  project_name  = var.project_name
  environment   = var.environment
  commn_tags    = var.commn_tags
  mysql_sg_tags = var.mysql_sg_tags
  vpc_id        = data.aws_ssm_parameter.vpc_id.value
}

module "sg_backend" {
  source          = "git::https://github.com/naveenrajoli4/ter-sg-module-dev.git?ref=main"
  sg_name         = "backend"
  description     = "Created for backend instances in expense prod"
  location        = var.location
  project_name    = var.project_name
  environment     = var.environment
  commn_tags      = var.commn_tags
  backend_sg_tags = var.backend_sg_tags
  vpc_id          = data.aws_ssm_parameter.vpc_id.value
}

module "sg_frontend" {
  source           = "git::https://github.com/naveenrajoli4/ter-sg-module-dev.git?ref=main"
  sg_name          = "fronend"
  description      = "Created for frontend instances in expense prod"
  location         = var.location
  project_name     = var.project_name
  environment      = var.environment
  commn_tags       = var.commn_tags
  frontend_sg_tags = var.frontend_sg_tags
  vpc_id           = data.aws_ssm_parameter.vpc_id.value
}

# Security grup for bastion server
module "sg_bastion" {
  source          = "git::https://github.com/naveenrajoli4/ter-sg-module-dev.git?ref=main"
  sg_name         = "bastion"
  description     = "Created for bastion instances in expense prod"
  location        = var.location
  project_name    = var.project_name
  environment     = var.environment
  commn_tags      = var.commn_tags
  bastion_sg_tags = var.bastion_sg_tags
  vpc_id          = data.aws_ssm_parameter.vpc_id.value
}

# VPN Ports are 22, 443, 1194, 943
module "sg_vpn" {
  source       = "git::https://github.com/naveenrajoli4/ter-sg-module-dev.git?ref=main"
  sg_name      = "vpn"
  description  = "Created for vpn in expense prod"
  location     = var.location
  project_name = var.project_name
  environment  = var.environment
  commn_tags   = var.commn_tags
  vpc_id       = data.aws_ssm_parameter.vpc_id.value
}

# Security group for app load balancer service
module "sg_app_alb" {
  source       = "git::https://github.com/naveenrajoli4/ter-sg-module-dev.git?ref=main"
  sg_name      = "app_alb"
  description  = "Created for backend application load balancer in expense prod"
  location     = var.location
  project_name = var.project_name
  environment  = var.environment
  commn_tags   = var.commn_tags
  vpc_id       = data.aws_ssm_parameter.vpc_id.value
}

# Accepting traffic from app load balancer seurity group to bastion security group 
resource "aws_security_group_rule" "app_alb_bastion" {
  type                     = "ingress"
  from_port                = "80"
  to_port                  = "80"
  protocol                 = "tcp"
  security_group_id        = module.sg_app_alb.sg_id
  source_security_group_id = module.sg_bastion.sg_id
}

# incoming traffic for bastion security group
resource "aws_security_group_rule" "bastion_public" {
  type              = "ingress"
  from_port         = 22
  to_port           = 22
  protocol          = "tcp"
  cidr_blocks       = ["0.0.0.0/0"]
  security_group_id = module.sg_bastion.sg_id
}

resource "aws_security_group_rule" "vpn_22" {
  type              = "ingress"
  from_port         = 22
  to_port           = 22
  protocol          = "tcp"
  cidr_blocks       = ["0.0.0.0/0"]
  security_group_id = module.sg_vpn.sg_id
}

resource "aws_security_group_rule" "vpn_443" {
  type              = "ingress"
  from_port         = 443
  to_port           = 443
  protocol          = "tcp"
  cidr_blocks       = ["0.0.0.0/0"]
  security_group_id = module.sg_vpn.sg_id
}

resource "aws_security_group_rule" "vpn_943" {
  type              = "ingress"
  from_port         = 943
  to_port           = 943
  protocol          = "tcp"
  cidr_blocks       = ["0.0.0.0/0"]
  security_group_id = module.sg_vpn.sg_id
}

resource "aws_security_group_rule" "vpn_1194" {
  type              = "ingress"
  from_port         = 1194
  to_port           = 1194
  protocol          = "tcp"
  cidr_blocks       = ["0.0.0.0/0"]
  security_group_id = module.sg_vpn.sg_id
}

# Accepting traffic from app load balancer seurity group to vpn security group 
resource "aws_security_group_rule" "vpn_app_alb" {
  type                     = "ingress"
  from_port                = 80
  to_port                  = 80
  protocol                 = "tcp"
  security_group_id        = module.sg_app_alb.sg_id
  source_security_group_id = module.sg_vpn.sg_id
}

# Accepting traffic from mysql seurity group to bastion security group 
resource "aws_security_group_rule" "bastion_rbs" {
  type                     = "ingress"
  from_port                = 3306
  to_port                  = 3306
  protocol                 = "tcp"
  security_group_id        = module.sg_mysql.sg_id
  source_security_group_id = module.sg_bastion.sg_id
}

# Accepting traffic from mysql seurity group to vpn security group 
resource "aws_security_group_rule" "vpn_rbs" {
  type                     = "ingress"
  from_port                = 3306
  to_port                  = 3306
  protocol                 = "tcp"
  security_group_id        = module.sg_mysql.sg_id
  source_security_group_id = module.sg_vpn.sg_id
}

# Accepting traffic from backend seurity group to vpn security group 
resource "aws_security_group_rule" "vpn_backend" {
  type                     = "ingress"
  from_port                = 22
  to_port                  = 22
  protocol                 = "tcp"
  security_group_id        = module.sg_backend.sg_id
  source_security_group_id = module.sg_vpn.sg_id
}

# Accepting traffic from backend seurity group to mysql security group 
resource "aws_security_group_rule" "backend_mysql" {
  type                     = "ingress"
  from_port                = 3306
  to_port                  = 3306
  protocol                 = "tcp"
  security_group_id        = module.sg_mysql.sg_id
  source_security_group_id = module.sg_backend.sg_id
}