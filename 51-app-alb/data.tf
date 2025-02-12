data "aws_ssm_parameter" "vpc_id" {
  name = "/${var.location}/${var.project_name}/${var.environment}/vpcid"
}

data "aws_ssm_parameter" "sg_app_alb" {
  name = "/${var.location}/${var.project_name}/${var.environment}/sg_app_alb"
}

data "aws_ssm_parameter" "private_subnet_ids" {
  name = "/${var.location}/${var.project_name}/${var.environment}/private_subnet_ids"
}

