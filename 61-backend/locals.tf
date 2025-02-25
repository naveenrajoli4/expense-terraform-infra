locals {
  instncetype       = "t3.micro"
  private_subnet_id = split(",", data.aws_ssm_parameter.private_subnet_ids.value)[0]
  private_subnet_ids = split(",", data.aws_ssm_parameter.private_subnet_ids.value)
  vpc_id            = data.aws_ssm_parameter.vpc_id.value
  sg_backend_id     = data.aws_ssm_parameter.sg_backend_id.value
}