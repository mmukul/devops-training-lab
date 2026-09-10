output "lab_instance_id" {
  value = aws_instance.lab.id
}

output "lab_public_ip" {
  value = aws_instance.lab.public_ip
}

output "api_url" {
  value = aws_apigatewayv2_stage.default.invoke_url
}

output "ssm_console_url" {
  value = "https://${var.aws_region}.console.aws.amazon.com/systems-manager/session-manager/sessions"
}
