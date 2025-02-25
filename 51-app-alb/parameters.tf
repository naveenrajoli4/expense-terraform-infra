resource "aws_ssm_parameter" "app_alb_listner_arn" {
  name  = "/${var.location}/${var.project_name}/${var.environment}/app_alb_listner_arn"
  type  = "String"
  value = aws_lb_listener.http.arn
}