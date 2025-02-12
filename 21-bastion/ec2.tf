resource "aws_instance" "my_instance" {
  ami                    = data.aws_ami.rhel9.id
  instance_type          = local.instncetype
  vpc_security_group_ids = [data.aws_ssm_parameter.sg_bastion_id.value]
  subnet_id              = local.public_subnet_ids
  tags = merge(
    var.commn_tags,
    {
      Name = "${var.location}-${var.project_name}-${var.environment}-bastion"
    }

  )
}
