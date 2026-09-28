data "archive_file" "stop_zip" {
  type        = "zip"
  source_file = "${path.module}/../lambda/stop_instances.py"
  output_path = "${path.module}/stop_instances.zip"
}

data "archive_file" "start_zip" {
  type        = "zip"
  source_file = "${path.module}/../lambda/start_instances.py"
  output_path = "${path.module}/start_instances.zip"
}

resource "aws_lambda_function" "stop_instances" {
  function_name    = "cost-optimizer-stop-instances"
  role             = aws_iam_role.lambda_ec2_scheduler.arn
  handler          = "stop_instances.handler"
  runtime          = "python3.12"
  filename         = data.archive_file.stop_zip.output_path
  source_code_hash = data.archive_file.stop_zip.output_base64sha256
  timeout          = 30
}

resource "aws_lambda_function" "start_instances" {
  function_name    = "cost-optimizer-start-instances"
  role             = aws_iam_role.lambda_ec2_scheduler.arn
  handler          = "start_instances.handler"
  runtime          = "python3.12"
  filename         = data.archive_file.start_zip.output_path
  source_code_hash = data.archive_file.start_zip.output_base64sha256
  timeout          = 30
}
