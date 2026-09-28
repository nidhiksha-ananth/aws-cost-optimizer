output "stop_lambda_name" {
  value = aws_lambda_function.stop_instances.function_name
}

output "start_lambda_name" {
  value = aws_lambda_function.start_instances.function_name
}
