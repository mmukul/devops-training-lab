resource "aws_cloudwatch_event_rule" "expiry" {
  name                = "${var.project_name}-expiry-check"
  description         = "Checks for expired lab sessions every 5 minutes"
  schedule_expression = "rate(5 minutes)"
}

resource "aws_cloudwatch_event_target" "expiry" {
  rule = aws_cloudwatch_event_rule.expiry.name
  arn  = aws_lambda_function.api.arn
  input = jsonencode({ action = "expire" })
}

resource "aws_lambda_permission" "eventbridge" {
  statement_id  = "AllowEventBridgeInvoke"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.api.function_name
  principal     = "events.amazonaws.com"
  source_arn    = aws_cloudwatch_event_rule.expiry.arn
}
