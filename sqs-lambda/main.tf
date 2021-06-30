terraform {
  required_providers {
    aws = {
      source = "hashicorp/aws"
    }
  }
}

resource "aws_sqs_queue" "this" {
  name                      = var.sqs_name
  delay_seconds             = 90
  max_message_size          = 2048
  message_retention_seconds = 86400
  receive_wait_time_seconds = 10

  tags = {
    Environment = var.environment
  }
}

resource "aws_iam_role_policy" "this" {
  name = "test_policy"
  role = aws_iam_role.iam_for_lambda.id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = [
          "sqs:*",
          "lambda:*",
          "logs:*"
        ]
        Effect   = "Allow"
        Resource = "*"
      },
    ]
  })
}

resource "aws_iam_role" "iam_for_lambda" {
  name = "iam_for_lambda"

  assume_role_policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Action": "sts:AssumeRole",
      "Principal": {
        "Service": "lambda.amazonaws.com"
      },
      "Effect": "Allow",
      "Sid": ""
    }
  ]
}
EOF
}

resource "aws_lambda_permission" "with_sqs" {
  statement_id  = "AllowSQS"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.this.function_name
  principal     = "sqs.amazonaws.com"
  source_arn    = aws_sqs_queue.this.arn
}


resource "aws_lambda_function" "this" {
  filename      = var.lambda_filename
  function_name = "lambda_function_name"
  role          = aws_iam_role.iam_for_lambda.arn
  handler       = "function.test"

  runtime = "go1.x"

  depends_on = [
    aws_cloudwatch_log_group.this,
  ]

  tags = {
    Enviroment = var.environment
  }
}

resource "aws_lambda_event_source_mapping" "example" {
  event_source_arn = aws_sqs_queue.this.arn
  function_name    = aws_lambda_function.this.arn
}


# This manages the CloudWatch Log Group for the Lambda Function.
resource "aws_cloudwatch_log_group" "this" {
  name              = "/aws/lambda/lambda_function_name"
  retention_in_days = 14
}
