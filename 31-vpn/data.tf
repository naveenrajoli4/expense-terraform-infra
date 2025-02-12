data "aws_ami" "vpn" {
  most_recent = true
  owners      = ["679593333241"]

  filter {
    name   = "name"
    values = ["OpenVPN Access Server Community Image-fe8020db-*"]
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

data "aws_ssm_parameter" "public_subnet_ids" {
  name = "/${var.location}/${var.project_name}/${var.environment}/public_subnet_ids"
}

data "aws_ssm_parameter" "sg_vpn_id" {
  name = "/${var.location}/${var.project_name}/${var.environment}/sg_vpn_id"
}

output "ami-id" {
  value = data.aws_ami.vpn.id
}


