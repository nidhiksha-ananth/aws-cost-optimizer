variable "alert_email" {
  description = "Email address to receive budget and tagging compliance alerts"
  type        = string
}

variable "budget_limit_usd" {
  description = "Monthly budget limit in USD"
  type        = number
  default     = 10
}
