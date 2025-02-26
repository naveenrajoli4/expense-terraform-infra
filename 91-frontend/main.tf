resource "aws_instance" "frontend" {
  ami                    = data.aws_ami.rhel9.id
  instance_type          = local.instncetype
  vpc_security_group_ids = [data.aws_ssm_parameter.sg_frontend_id.value]
  subnet_id              = local.public_subnet_id
  tags = merge(
    var.commn_tags,
    {
      Name = "${var.location}-${var.project_name}-${var.environment}-frontend"
    }

  )
}

resource "null_resource" "frontend" {
  # Changes to any instance of the instances requires re-provisioning
  triggers = {
    instance_ids = aws_instance.frontend.id
  }

  # Bootstrap script can run on any instance of the cluster
  # So we just choose the first in this case
  connection {
    host = aws_instance.frontend.private_ip
    type = "ssh"
    user = "ec2-user"
    password = "DevOps321"
  }

  provisioner "file" {
    source      = "frontend.sh"
    destination = "/tmp/frontend.sh"
        
  }

  provisioner "remote-exec" {
    # Bootstrap script called with private_ip of each node in the cluster
    inline = [
      "sudo chmod +x /tmp/frontend.sh",
      "sudo /tmp/frontend.sh ${var.environment}"
    ]
  }
}


#stop the ec2 instance
resource "aws_ec2_instance_state" "frontend_stop" {
  instance_id = aws_instance.frontend.id
  state       = "stopped"
  depends_on = [null_resource.frontend]  
}

resource "aws_ami_from_instance" "frontend" {
  name = "${var.location}-${var.project_name}-${var.environment}-frontend-ami"
  source_instance_id = aws_instance.frontend.id
  depends_on = [aws_ec2_instance_state.frontend_stop]
}

resource "null_resource" "frontend_delete" {
  triggers = {
    ami_id = aws_instance.frontend.id
  }

  provisioner "local-exec" {
   command = "aws ec2 terminate-instances --instance-ids ${aws_instance.frontend.id}"
  }
  
  depends_on = [aws_ami_from_instance.frontend]
}

resource "aws_lb_target_group" "frontend_target_group" {
  name        = "${var.location}-${var.project_name}-${var.environment}-frontend-tg"
  port        = 80
  protocol    = "HTTP"
  vpc_id      = data.aws_ssm_parameter.vpc_id.value
  target_type = "instance"
  deregistration_delay = 60

  health_check {
    path                = "/"
    protocol            = "HTTP"
    port                = "80"
    interval            = 10
    timeout             = 5
    healthy_threshold   = 2
    unhealthy_threshold = 2
    matcher = "200-299"
  }
  
}

resource "aws_launch_template" "frontend_lt" {
  name   = "${var.location}-${var.project_name}-${var.environment}-frontend-lt"
  image_id      = aws_ami_from_instance.frontend.id
  instance_initiated_shutdown_behavior = "terminate"
  instance_type = local.instncetype
  update_default_version = true

  vpc_security_group_ids = [local.sg_frontend_id]

  tag_specifications {
    resource_type = "instance"
    tags = merge(
      var.commn_tags,
      {
        Name = "${var.location}-${var.project_name}-${var.environment}-frontend-lt"
      }
    )
  }

}

resource "aws_autoscaling_group" "frontend_asg" {
  name = "${var.location}-${var.project_name}-${var.environment}-frontend-asg"
  desired_capacity = 1
  max_size         = 10
  min_size         = 1
  health_check_grace_period = 180 # 3 minutes for instance to intialise
  health_check_type = "ELB"
  target_group_arns = [aws_lb_target_group.frontend_target_group.arn]
  launch_template {
    id      = aws_launch_template.frontend_lt.id
    version = "$Latest"
  }
  vpc_zone_identifier = local.public_subnet_ids
  instance_refresh {
    strategy = "Rolling"
     preferences {
      min_healthy_percentage = 50
    }
    triggers = ["launch_template"]
  }
  
  tag {
    key                 = "Name"
    value               = "${var.location}-${var.project_name}-${var.environment}-frontend-asg"
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

resource "aws_autoscaling_policy" "frontend_asg_policy" {
  name                   = "${var.location}-${var.project_name}-${var.environment}-frontend-asg-policy"
  policy_type           = "TargetTrackingScaling"
  autoscaling_group_name = aws_autoscaling_group.frontend_asg.name
  target_tracking_configuration {
    predefined_metric_specification {
      predefined_metric_type = "ASGAverageCPUUtilization"
    }
    target_value = 70.0
  }
}

resource "aws_lb_listener_rule" "frontend" {
  listener_arn = data.aws_ssm_parameter.web_alb_listner_arn.value
  priority     = 100
  action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.frontend_target_group.arn
  }
  condition {
    host_header {
      values = ["expense-${var.environment}.${var.domain_name}"]
    }
  }
}

