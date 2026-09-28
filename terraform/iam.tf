# Least-privilege IAM: this role can only describe/stop/start EC2 instances
# and write its own logs -- nothing else. Worth mentioning in interviews as
# a deliberate security choice, not an oversight.

resource "aws_iam_role" "lambda_ec2_scheduler" {
  name = "cost-optimizer-ec2-scheduler"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Action    = "sts:AssumeRole"
      Effect    = "Allow"
      Principal = { Service = "lambda.amazonaws.com" }
    }]
  })
}

resource "aws_iam_role_policy" "lambda_ec2_permissions" {
  name = "ec2-start-stop"
  role = aws_iam_role.lambda_ec2_scheduler.id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect   = "Allow"
        Action   = ["ec2:DescribeInstances", "ec2:StopInstances", "ec2:StartInstances"]
        Resource = "*"
      },
      {
        Effect   = "Allow"
        Action   = ["logs:CreateLogGroup", "logs:CreateLogStream", "logs:PutLogEvents"]
        Resource = "arn:aws:logs:*:*:*"
      }
    ]
  })
}
