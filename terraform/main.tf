terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~>5.0"
    }
  }
}

provider "aws" {
  region = var.region
}

# -------------------------------
# IAM Role for Lambda
# -------------------------------
resource "aws_iam_role" "lambda_role" {
  name = "${var.function_name}-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17",
    Statement = [{
      Effect    = "Allow"
      Principal = { Service = "lambda.amazonaws.com" }
      Action    = "sts:AssumeRole"
    }]
  })
}

# Attach basic execution policy
resource "aws_iam_role_policy_attachment" "lambda_basic_policy" {
  role       = aws_iam_role.lambda_role.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSLambdaBasicExecutionRole"
}

# -------------------------------
# Zip Lambda code
# -------------------------------
data "archive_file" "lambda_zip" {
  type        = "zip"
  source_dir  = "${path.module}/../lambda"
  output_path = "${path.module}/lambda.zip"
}

# -------------------------------
# Create Lambda function
# -------------------------------
resource "aws_lambda_function" "lambda_function" {
  function_name    = var.function_name
  runtime          = "nodejs18.x"
  handler          = "index.handler"
  role             = aws_iam_role.lambda_role.arn
  filename         = data.archive_file.lambda_zip.output_path
  source_code_hash = data.archive_file.lambda_zip.output_base64sha256

  environment {
    variables = {
      NODE_ENV = "production"
    }
  }
}

# -------------------------------
# CloudWatch EventBridge Rule (every 1 minute)
# -------------------------------
resource "aws_cloudwatch_event_rule" "every_minute" {
  name                = var.schedule_name
  description         = var.schedule_description
  schedule_expression = var.schedule_interval
}

# EventBridge Target to invoke Lambda
resource "aws_cloudwatch_event_target" "lambda_target" {
  rule      = aws_cloudwatch_event_rule.every_minute.name
  target_id = "LambdaTarget"
  arn       = aws_lambda_function.lambda_function.arn
}

# Permission for EventBridge to invoke Lambda
resource "aws_lambda_permission" "allow_eventbridge" {
  statement_id  = "AllowExecutionFromCloudWatch"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.lambda_function.arn
  principal     = "events.amazonaws.com"
  source_arn    = aws_cloudwatch_event_rule.every_minute.arn
}

# -------------------------------
# Output Lambda ARN
# -------------------------------
output "lambda_arn" {
  value = aws_lambda_function.lambda_function.arn
}

# Output EventBridge Rule ARN
output "event_rule_arn" {
  value = aws_cloudwatch_event_rule.every_minute.arn
}
