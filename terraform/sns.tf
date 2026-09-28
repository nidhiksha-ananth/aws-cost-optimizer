# Single SNS topic reused for both the AWS Budget alert and the tagging
# compliance Lambda -- one place to subscribe your email, notifications
# from multiple sources.

resource "aws_sns_topic" "cost_alerts" {
  name = "cost-optimizer-alerts"
}

resource "aws_sns_topic_subscription" "email_alert" {
  topic_arn = aws_sns_topic.cost_alerts.arn
  protocol  = "email"
  endpoint  = var.alert_email
}
