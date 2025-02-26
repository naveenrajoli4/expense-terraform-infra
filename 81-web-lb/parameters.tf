resource "aws_ssm_parameter" "web_alb_listner_arn" {
  name  = "/${var.location}/${var.project_name}/${var.environment}/web_alb_listner_arn"
  type  = "String"
  value = aws_lb_listener.https.arn
}