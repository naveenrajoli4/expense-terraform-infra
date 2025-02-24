resource "aws_instance" "backend" {
  ami                    = data.aws_ami.rhel9.id
  instance_type          = local.instncetype
  vpc_security_group_ids = [data.aws_ssm_parameter.sg_backend_id.value]
  subnet_id              = local.private_subnet_ids
  tags = merge(
    var.commn_tags,
    {
      Name = "${var.location}-${var.project_name}-${var.environment}-backend"
    }

  )
}

resource "null_resource" "backend" {
  # Changes to any instance of the instances requires re-provisioning
  triggers = {
    instance_ids = aws_instance.backend.id
  }

  # Bootstrap script can run on any instance of the cluster
  # So we just choose the first in this case
  connection {
    host = aws_instance.backend.private_ip
    type = "ssh"
    user = "ec2-user"
    password = "DevOps321"
  }

  provisioner "file" {
    source      = "backend.sh"
    destination = "/tmp/backend.sh"
        
  }

  provisioner "remote-exec" {
    # Bootstrap script called with private_ip of each node in the cluster
    inline = [
      "chmod +x /tmp/backend.sh",
      "sudo /tmp/backend.sh ${var.environment}"
    ]
  }
}
