output "app_alb" {
  value     = aws_lb.app_alb
  sensitive = true # Marks the output as sensitive
}