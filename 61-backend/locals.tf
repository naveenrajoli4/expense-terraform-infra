locals {
  instncetype       = "t3.micro"
  private_subnet_ids = split(",", data.aws_ssm_parameter.private_subnet_ids.value)[0]

}