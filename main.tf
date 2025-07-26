provider "aws" {
  region = "ap-south-1" # Change region if needed
}

# --- IAM Role for Lambda ---
resource "aws_iam_role" "lambda_ec2_role" {
  name = "lambda-ec2-start-stop-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Principal = {
          Service = "lambda.amazonaws.com"
        }
      }
    ]
  })
}

# Attach policy for Lambda to write logs
resource "aws_iam_role_policy_attachment" "lambda_logs" {
  role       = aws_iam_role.lambda_ec2_role.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSLambdaBasicExecutionRole"
}

# Policy for EC2 Start/Stop
resource "aws_iam_role_policy" "lambda_ec2_policy" {
  name = "lambda-ec2-start-stop"
  role = aws_iam_role.lambda_ec2_role.id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect   = "Allow"
        Action   = ["ec2:StartInstances", "ec2:StopInstances"]
        Resource = "*"
      }
    ]
  })
}

# --- Lambda Function ---
resource "aws_lambda_function" "ec2_start_stop" {
  function_name = "EC2StartStopDemo"
  role          = aws_iam_role.lambda_ec2_role.arn
  handler       = "lambda_function.lambda_handler"
  runtime       = "python3.12"

  filename         = "lambda.zip"       # We will package the code into this
  source_code_hash = filebase64sha256("lambda.zip")
}

# --- EventBridge Rule for Start (4:00 PM IST = 10:30 UTC) ---
resource "aws_cloudwatch_event_rule" "start_rule" {
  name                = "EC2StartDemo"
  schedule_expression = "cron(30 10 * * ? *)"
}

resource "aws_cloudwatch_event_target" "start_target" {
  rule      = aws_cloudwatch_event_rule.start_rule.name
  target_id = "EC2Start"
  arn       = aws_lambda_function.ec2_start_stop.arn
  input     = jsonencode({ action = "start" })
}

# --- EventBridge Rule for Stop (4:30 PM IST = 11:00 UTC) ---
resource "aws_cloudwatch_event_rule" "stop_rule" {
  name                = "EC2StopDemo"
  schedule_expression = "cron(0 11 * * ? *)"
}

resource "aws_cloudwatch_event_target" "stop_target" {
  rule      = aws_cloudwatch_event_rule.stop_rule.name
  target_id = "EC2Stop"
  arn       = aws_lambda_function.ec2_start_stop.arn
  input     = jsonencode({ action = "stop" })
}

# Lambda permission to allow EventBridge to invoke it
resource "aws_lambda_permission" "allow_start" {
  statement_id  = "AllowStartRule"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.ec2_start_stop.function_name
  principal     = "events.amazonaws.com"
  source_arn    = aws_cloudwatch_event_rule.start_rule.arn
}

resource "aws_lambda_permission" "allow_stop" {
  statement_id  = "AllowStopRule"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.ec2_start_stop.function_name
  principal     = "events.amazonaws.com"
  source_arn    = aws_cloudwatch_event_rule.stop_rule.arn
}
