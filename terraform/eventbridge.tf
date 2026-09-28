# EventBridge = the "cron job" that triggers each Lambda on a schedule.
# This is what makes the whole thing automatic -- no one has to remember
# to run anything.

resource "aws_cloudwatch_event_rule" "stop_schedule" {
  name                = "cost-optimizer-stop-schedule"
  schedule_expression = var.stop_schedule
}

resource "aws_cloudwatch_event_target" "stop_target" {
  rule = aws_cloudwatch_event_rule.stop_schedule.name
  arn  = aws_lambda_function.stop_instances.arn
}

resource "aws_lambda_permission" "allow_eventbridge_stop" {
  statement_id  = "AllowEventBridgeStop"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.stop_instances.function_name
  principal     = "events.amazonaws.com"
  source_arn    = aws_cloudwatch_event_rule.stop_schedule.arn
}

resource "aws_cloudwatch_event_rule" "start_schedule" {
  name                = "cost-optimizer-start-schedule"
  schedule_expression = var.start_schedule
}

resource "aws_cloudwatch_event_target" "start_target" {
  rule = aws_cloudwatch_event_rule.start_schedule.name
  arn  = aws_lambda_function.start_instances.arn
}

resource "aws_lambda_permission" "allow_eventbridge_start" {
  statement_id  = "AllowEventBridgeStart"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.start_instances.function_name
  principal     = "events.amazonaws.com"
  source_arn    = aws_cloudwatch_event_rule.start_schedule.arn
}
