resource "aws_ssm_parameter" "sg_mysql_id" {
  name  = "/${var.location}/${var.project_name}/${var.environment}/sg_mysql_id"
  type  = "String"
  value = module.sg_mysql.sg_id
}

resource "aws_ssm_parameter" "sg_backend_id" {
  name  = "/${var.location}/${var.project_name}/${var.environment}/sg_backend_id"
  type  = "String"
  value = module.sg_backend.sg_id
}

resource "aws_ssm_parameter" "sg_frontend_id" {
  name  = "/${var.location}/${var.project_name}/${var.environment}/sg_frontend_id"
  type  = "String"
  value = module.sg_frontend.sg_id
}

resource "aws_ssm_parameter" "sg_bastion_id" {
  name  = "/${var.location}/${var.project_name}/${var.environment}/sg_bastion_id"
  type  = "String"
  value = module.sg_bastion.sg_id
}

resource "aws_ssm_parameter" "sg_app_alb" {
  name  = "/${var.location}/${var.project_name}/${var.environment}/sg_app_alb"
  type  = "String"
  value = module.sg_app_alb.sg_id
}

resource "aws_ssm_parameter" "sg_web_alb" {
  name  = "/${var.location}/${var.project_name}/${var.environment}/sg_web_alb"
  type  = "String"
  value = module.sg_web_alb.sg_id
}

resource "aws_ssm_parameter" "sg_vpn_id" {
  name  = "/${var.location}/${var.project_name}/${var.environment}/sg_vpn_id"
  type  = "String"
  value = module.sg_vpn.sg_id
}