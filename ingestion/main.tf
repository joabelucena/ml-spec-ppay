
# Cloud watch event creation
resource "aws_cloudwatch_event_rule" "punk_api_call_rule" {
  name                = "${var.parameter.account_alias}_punk-api-call_rule"
  description         = "Trggers the Lambda function responsible for starting the process."
  is_enabled          = true
  tags                = var.tags
  schedule_expression = "rate(1 minute)"
}

resource "aws_cloudwatch_event_target" "punk_api_call_target" {
  rule      = aws_cloudwatch_event_rule.punk_api_call_rule.name
  arn       = aws_lambda_function.punk_api_call.arn
}

# Layer creation
resource "aws_lambda_layer_version" "lambda_layer" {
  filename    = "${path.module}/resources/python.zip"
  layer_name  = "Integration"
  description = "Provides packages for HTTP API integration"

  compatible_runtimes = ["python3.6"]
}

data "archive_file" "source_file" {
  type        = "zip"
  source_file = "${path.module}/resources/lambda_function.py"
  output_path = "${path.module}/resources/lambda_function.zip"
}

# Lambda creation
resource "aws_lambda_function" "punk_api_call" {
  filename         = data.archive_file.source_file.output_path
  function_name    = "${var.parameter.account_alias}_punk-api-call_lambda"
  role             = var.iam_lambda_role_arn
  handler          = "lambda_function.lambda_handler"
  layers           = [aws_lambda_layer_version.lambda_layer.arn]
  tags             = var.tags
  source_code_hash = filebase64sha256(data.archive_file.source_file.output_path)

  runtime = "python3.6"

  environment {
    variables = {
      API_URL     = "https://api.punkapi.com/v2/beers/random",
      REGION      = "us-east-1",
      STREAM_NAME = var.kinesis_stream_name
    }
  }
}

resource "aws_lambda_permission" "allow_cloudwatch" {
  statement_id  = "AllowExecutionFromCloudWatch"
  action        = "lambda:InvokeFunction"
  principal     = "events.amazonaws.com"
  function_name = aws_lambda_function.punk_api_call.function_name
  source_arn    = aws_cloudwatch_event_rule.punk_api_call_rule.arn
}
