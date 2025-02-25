resource "aws_instance" "backend" {
  ami                    = data.aws_ami.rhel9.id
  instance_type          = local.instncetype
  vpc_security_group_ids = [data.aws_ssm_parameter.sg_backend_id.value]
  subnet_id              = local.private_subnet_id
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
      "sudo chmod +x /tmp/backend.sh",
      "sudo /tmp/backend.sh ${var.environment}"
    ]
  }
}

#stop the ec2 instance
resource "aws_ec2_instance_state" "backend_stop" {
  instance_id = aws_instance.backend.id
  state       = "stopped"
  depends_on = [null_resource.backend]  
}

resource "aws_ami_from_instance" "backend" {
  name = "${var.location}-${var.project_name}-${var.environment}-backend-ami"
  source_instance_id = aws_instance.backend.id
  depends_on = [aws_ec2_instance_state.backend_stop]
}

resource "null_resource" "backend_delete" {
  triggers = {
    ami_id = aws_instance.backend.id
  }

  provisioner "local-exec" {
   command = "aws ec2 terminate-instances --instance-ids ${aws_instance.backend.id}"
  }
  
  depends_on = [aws_ami_from_instance.backend]
}

resource "aws_lb_target_group" "backend_target_group" {
  name        = "${var.location}-${var.project_name}-${var.environment}-backend-tg"
  port        = 8080
  protocol    = "HTTP"
  vpc_id      = data.aws_ssm_parameter.vpc_id.value
  target_type = "instance"
  deregistration_delay = 60

  health_check {
    path                = "/health"
    protocol            = "HTTP"
    port                = "8080"
    interval            = 10
    timeout             = 5
    healthy_threshold   = 2
    unhealthy_threshold = 2
    matcher = "200-299"
  }
  
}

resource "aws_launch_template" "backend_lt" {
  name   = "${var.location}-${var.project_name}-${var.environment}-backend-lt"
  image_id      = aws_ami_from_instance.backend.id
  instance_initiated_shutdown_behavior = "terminate"
  instance_type = local.instncetype
  update_default_version = true

  vpc_security_group_ids = [local.sg_backend_id]

  tag_specifications {
    resource_type = "instance"
    tags = merge(
      var.commn_tags,
      {
        Name = "${var.location}-${var.project_name}-${var.environment}-backend-lt"
      }
    )
  }

}

resource "aws_autoscaling_group" "backend_asg" {
  name = "${var.location}-${var.project_name}-${var.environment}-backend-asg"
  desired_capacity = 1
  max_size         = 1
  min_size         = 1
  health_check_grace_period = 180 # 3 minutes for instance to intialise
  health_check_type = "ELB"
  target_group_arns = [aws_lb_target_group.backend_target_group.arn]
  launch_template {
    id      = aws_launch_template.backend_lt.id
    version = "$Latest"
  }
  vpc_zone_identifier = local.private_subnet_ids
  instance_refresh {
    strategy = "Rolling"
     preferences {
      min_healthy_percentage = 50
    }
    triggers = ["launch_template"]
  }
  
  tag {
    key                 = "Name"
    value               = "${var.location}-${var.project_name}-${var.environment}-backend-asg"
    propagate_at_launch = true
  }

  timeouts {
    delete = "10m"
  }

  tag {
    key                 = "Project"
    value               = "expense"
    propagate_at_launch = false
  }

  tag {
    key                 = "Environment"
    value               = "dev"
    propagate_at_launch = false
  }
}

resource "aws_autoscaling_policy" "backend_asg_policy" {
  name                   = "${var.location}-${var.project_name}-${var.environment}-backend-asg-policy"
  policy_type           = "TargetTrackingScaling"
  autoscaling_group_name = aws_autoscaling_group.backend_asg.name
  target_tracking_configuration {
    predefined_metric_specification {
      predefined_metric_type = "ASGAverageCPUUtilization"
    }
    target_value = 70.0
  }
}

resource "aws_lb_listener_rule" "backend" {
  listener_arn = data.aws_ssm_parameter.app_alb_listner_arn.value
  priority     = 100
  action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.backend_target_group.arn
  }
  condition {
    host_header {
      values = ["backend.app-prod.${var.domain_name}"]
    }
  }
}
