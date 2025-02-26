locals {
  instncetype       = "t3.micro"
  public_subnet_id = split(",", data.aws_ssm_parameter.public_subnet_ids.value)[0]
  public_subnet_ids = split(",", data.aws_ssm_parameter.public_subnet_ids.value)
  vpc_id            = data.aws_ssm_parameter.vpc_id.value
  sg_frontend_id     = data.aws_ssm_parameter.sg_frontend_id.value
}