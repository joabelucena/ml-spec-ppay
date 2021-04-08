
# Cloud watch event creation
resource "aws_cloudwatch_event_rule" "punk_api_call_rule" {
  name        = "punk_api_call_rule"
  description = "Capture each AWS Console Sign In"
  is_enabled = false

  schedule_expression = "rate(5 minutes)"
}

resource "aws_cloudwatch_event_target" "punk_api_call_target" {
  target_id = "punk_api_call_target"
  rule      = aws_cloudwatch_event_rule.punk_api_call_rule.name
  arn       = aws_lambda_function.punk_api_call.arn

}

# Layer creation
resource "aws_lambda_layer_version" "lambda_layer" {
  filename   = "ingestion/resources/python.zip"
  layer_name = "Integration"
  description = "Provides packages for HTTP API integration"

  compatible_runtimes = ["python3.6"]
}

# Lambda creation
resource "aws_lambda_function" "punk_api_call" {
  filename      = "ingestion/resources/lambda_function.zip"
  function_name = "lambda_punk_api_call"
  role          = var.iam_lambda_role_arn
  handler       = "lambda_function.lambda_handler"
  layers = [ aws_lambda_layer_version.lambda_layer.arn ]

  # The filebase64sha256() function is available in Terraform 0.11.12 and later
  # For Terraform 0.11.11 and earlier, use the base64sha256() function and the file() function:
  # source_code_hash = "${base64sha256(file("lambda_function_payload.zip"))}"
  source_code_hash = filebase64sha256("ingestion/resources/lambda_function.zip")

  runtime = "python3.6"

  environment {
    variables = {
      foo = "bar"
    }
  }
}