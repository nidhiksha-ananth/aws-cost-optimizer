resource "aws_iam_role" "tag_compliance" {
  name = "cost-optimizer-tag-compliance"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Action    = "sts:AssumeRole"
      Effect    = "Allow"
      Principal = { Service = "lambda.amazonaws.com" }
    }]
  })
}

resource "aws_iam_role_policy" "tag_compliance_permissions" {
  name = "tag-compliance-permissions"
  role = aws_iam_role.tag_compliance.id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect   = "Allow"
        Action   = ["ec2:DescribeInstances"]
        Resource = "*"
      },
      {
        Effect   = "Allow"
        Action   = ["sns:Publish"]
        Resource = aws_sns_topic.cost_alerts.arn
      },
      {
        Effect   = "Allow"
        Action   = ["logs:CreateLogGroup", "logs:CreateLogStream", "logs:PutLogEvents"]
        Resource = "arn:aws:logs:*:*:*"
      }
    ]
  })
}

data "archive_file" "tag_compliance_zip" {
  type        = "zip"
  source_file = "${path.module}/../lambda/tag_compliance.py"
  output_path = "${path.module}/tag_compliance.zip"
}

resource "aws_lambda_function" "tag_compliance" {
  function_name    = "cost-optimizer-tag-compliance"
  role             = aws_iam_role.tag_compliance.arn
  handler          = "tag_compliance.handler"
  runtime          = "python3.12"
  filename         = data.archive_file.tag_compliance_zip.output_path
  source_code_hash = data.archive_file.tag_compliance_zip.output_base64sha256
  timeout          = 30

  environment {
    variables = {
      SNS_TOPIC_ARN = aws_sns_topic.cost_alerts.arn
    }
  }
}

resource "aws_cloudwatch_event_rule" "tag_compliance_schedule" {
  name                = "cost-optimizer-tag-compliance-schedule"
  schedule_expression = "cron(0 4 * * ? *)" # 9:30 AM IST daily
}

resource "aws_cloudwatch_event_target" "tag_compliance_target" {
  rule = aws_cloudwatch_event_rule.tag_compliance_schedule.name
  arn  = aws_lambda_function.tag_compliance.arn
}

resource "aws_lambda_permission" "allow_eventbridge_tag_compliance" {
  statement_id  = "AllowEventBridgeTagCompliance"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.tag_compliance.function_name
  principal     = "events.amazonaws.com"
  source_arn    = aws_cloudwatch_event_rule.tag_compliance_schedule.arn
}
