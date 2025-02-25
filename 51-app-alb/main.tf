resource "aws_lb" "app_alb" {
  name = "${var.location}-${var.project_name}-${var.environment}-app-alb"
  #   vpc_id = data.aws_ssm_parameter.vpc_id.value
  internal           = true
  load_balancer_type = "application"
  security_groups    = [data.aws_ssm_parameter.sg_app_alb.value]
  subnets            = split(",", data.aws_ssm_parameter.private_subnet_ids.value)


  enable_deletion_protection = true # Prevents accidental deletion

  tags = merge(
    var.commn_tags,
    var.app_alb_tags,
    {
      Name = "${var.location}-${var.project_name}-${var.environment}-app-alb"
    }

  )
}

resource "aws_lb_listener" "http" {
  load_balancer_arn = aws_lb.app_alb.arn
  port              = "80"
  protocol          = "HTTP"

  default_action {
    type = "fixed-response"

    fixed_response {
      content_type = "text/html"
      message_body = "<h1>Hello, I am from backend APP ALB</h1>"
      status_code  = "200"
    }
  }
}

resource "aws_route53_record" "app_alb" {
  zone_id = var.zone_id
  name    = "*.app-prod.${var.domain_name}"
  type    = "A"

  # These are ALB DNS names and zone id information
  alias {
    name                   = aws_lb.app_alb.dns_name
    zone_id                = aws_lb.app_alb.zone_id
    evaluate_target_health = false
  }
}