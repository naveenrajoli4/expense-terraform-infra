data "aws_ami" "rhel9" {
  most_recent = true
  owners      = ["973714476881"]

  filter {
    name   = "name"
    values = ["RHEL-9-DevOps-Practice"]
  }

  filter {
    name   = "root-device-type"
    values = ["ebs"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }
}

data "aws_ssm_parameter" "private_subnet_ids" {
  name = "/${var.location}/${var.project_name}/${var.environment}/private_subnet_ids"
}

data "aws_ssm_parameter" "sg_backend_id" {
  name = "/${var.location}/${var.project_name}/${var.environment}/sg_backend_id"
 
}

output "ami-id" {
  value = data.aws_ami.rhel9.id
}

data "aws_ssm_parameter" "vpc_id" {
  name = "/${var.location}/${var.project_name}/${var.environment}/vpcid"
}


data "aws_ssm_parameter" "app_alb_listner_arn" {
  name = "/${var.location}/${var.project_name}/${var.environment}/app_alb_listner_arn"
}

