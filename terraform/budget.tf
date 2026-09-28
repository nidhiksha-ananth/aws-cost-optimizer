# A monthly cost budget that alerts via SNS (and therefore email) once
# actual spend crosses the threshold. This is the "proactive monitoring"
# half of cost optimization -- the Lambdas from Day 1 are the "automatic
# action" half.

resource "aws_budgets_budget" "monthly_cost" {
  name         = "cost-optimizer-monthly-budget"
  budget_type  = "COST"
  limit_amount = var.budget_limit_usd
  limit_unit   = "USD"
  time_unit    = "MONTHLY"

  notification {
    comparison_operator        = "GREATER_THAN"
    threshold                  = 80
    threshold_type             = "PERCENTAGE"
    notification_type          = "ACTUAL"
    subscriber_sns_topic_arns  = [aws_sns_topic.cost_alerts.arn]
  }

  notification {
    comparison_operator        = "GREATER_THAN"
    threshold                  = 100
    threshold_type             = "PERCENTAGE"
    notification_type          = "FORECASTED"
    subscriber_sns_topic_arns  = [aws_sns_topic.cost_alerts.arn]
  }
}
