terraform {
  required_providers {
    aws={
        source="hashicorp/aws"
        version="~>5.0"
    }
  }
}
provider "aws" {
  region = var.region
}

#IAM role for Lambda
resource "aws_iam_role" "lambda_role" {
    name="${var.function_name}-role"  
    assume_role_policy=jsonencode({
    Version="2012-10-17",
    Statement=[{
        Effect="Allow"
        Principal={Service="lambda.amazonaws.com"}
        Action="sts:AssumeRole"
    }]
    })
}

# Attach basic execeution policy
resource "aws_iam_role_policy_attachment" "lambda_basic_policy"{
    role = aws_iam_role.lambda_role.name
    policy_arn = "arn:aws:iam::aws:policy/service-role/AWSLambdaBasicExecutionRole"
}

#Zip Lamda Code
data "archive_file" "lambda_zip"{
    type="zip"
    source_dir = "${path.module}/../lambda"
    output_path = "${path.module}/lambda.zip"
}
# Create Lambda function
resource "aws_lambda_function" "lambda_function" {
  function_name = var.function_name
  runtime       = "nodejs18.x"
  handler       = "index.handler"
  role          = aws_iam_role.lambda_role.arn
  filename      = data.archive_file.lambda_zip.output_path
  source_code_hash = data.archive_file.lambda_zip.output_base64sha256

  environment {
    variables = {
      NODE_ENV = "production"
    }
  }
}

# Output Lambda ARN
output "lambda_arn" {
  value = aws_lambda_function.lambda_function.arn
}