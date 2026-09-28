variable "aws_region" {
  description = "AWS region"
  type        = string
  default     = "ap-south-1"
}

variable "stop_schedule" {
  description = "Cron expression for stopping instances (UTC). Default: 2:30 PM UTC = 8:00 PM IST"
  type        = string
  default     = "cron(30 14 * * ? *)"
}

variable "start_schedule" {
  description = "Cron expression for starting instances (UTC). Default: 3:30 AM UTC = 9:00 AM IST"
  type        = string
  default     = "cron(30 3 * * ? *)"
}
