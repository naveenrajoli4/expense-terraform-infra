resource "aws_lb" "web_alb" {
  name = "${var.location}-${var.project_name}-${var.environment}-web-alb"
  #   vpc_id = data.aws_ssm_parameter.vpc_id.value
  internal           = false
  load_balancer_type = "application"
  security_groups    = [data.aws_ssm_parameter.sg_web_alb.value]
  subnets            = split(",", data.aws_ssm_parameter.public_subnet_ids.value)


  enable_deletion_protection = false # Prevents accidental deletion

  tags = merge(
    var.commn_tags,
    var.web_alb_tags,
    {
      Name = "${var.location}-${var.project_name}-${var.environment}-web-alb"
    }

  )
}

resource "aws_lb_listener" "https" {
  load_balancer_arn = aws_lb.web_alb.arn
  port              = "443"
  protocol          = "HTTPS"
  ssl_policy        = "ELBSecurityPolicy-2016-08"
  certificate_arn   = data.aws_ssm_parameter.web_alb_certificate_arn.value

  default_action {
    type = "fixed-response"

    fixed_response {
      content_type = "text/html"
      message_body = "<h1>Hello, I am from frontend web ALB with HTTPS</h1>"
      status_code  = "200"
    }
  }
}

resource "aws_route53_record" "web_alb" {
  zone_id = var.zone_id
  name    = "expense-${var.environment}.${var.domain_name}"
  type    = "A"

  # These are ALB DNS names and zone id information
  alias {
    name                   = aws_lb.web_alb.dns_name
    zone_id                = aws_lb.web_alb.zone_id
    evaluate_target_health = false
  }
}