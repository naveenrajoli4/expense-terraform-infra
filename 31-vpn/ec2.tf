resource "aws_key_pair" "openvpnas" {
  key_name   = "openvpnas"
  public_key = file("E:\\AWS-DEVOPS\\openvpn-keypair\\openvpnas.pub")
}

resource "aws_instance" "vpn" {
  ami                    = data.aws_ami.vpn.id
  key_name               = aws_key_pair.openvpnas.key_name
  instance_type          = local.instncetype
  vpc_security_group_ids = [data.aws_ssm_parameter.sg_vpn_id.value]
  subnet_id              = local.public_subnet_ids
  user_data              = file("user-data.sh")
  tags = merge(
    var.commn_tags,
    {
      Name = "${var.location}-${var.project_name}-${var.environment}-vpn"
    }

  )
}

output "vpn_public_ip" {
  value = aws_instance.vpn.public_ip                                                                                                                      
}
