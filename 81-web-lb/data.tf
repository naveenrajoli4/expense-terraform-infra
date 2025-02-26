data "aws_ssm_parameter" "vpc_id" {
  name = "/${var.location}/${var.project_name}/${var.environment}/vpcid"
}

data "aws_ssm_parameter" "sg_web_alb" {
  name = "/${var.location}/${var.project_name}/${var.environment}/sg_web_alb"
}

data "aws_ssm_parameter" "public_subnet_ids" {
  name = "/${var.location}/${var.project_name}/${var.environment}/public_subnet_ids"
}


data "aws_ssm_parameter" "web_alb_certificate_arn" {
  name = "/${var.location}/${var.project_name}/${var.environment}/web_alb_certificate_arn"
}