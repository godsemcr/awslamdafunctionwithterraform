variable "region" {
  description = "AWS region to deploy the Lambda"
  type        = string
  default     = "eu-north-1"
}

variable "function_name" {
  description = "Lambda function name"
  type        = string
  default     = "hello-world-node-lambda"
}

variable "schedule_name" {
  description = "Name of the CloudWatch EventBridge rule"
  type        = string
  default     = "hello-world-node-lambda-schedule"
}

variable "schedule_description" {
  description = "Description of the schedule"
  type        = string
  default     = "Triggers Lambda every 1 minute indefinitely"
}

variable "schedule_interval" {
  description = "Schedule expression for EventBridge rule"
  type        = string
  default     = "rate(1 minute)"
}
