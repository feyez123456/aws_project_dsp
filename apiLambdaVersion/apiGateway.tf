resource "aws_apigatewayv2_api" "gateway" {
  name = "bonjourService"
  protocol_type = "HTTP"
}



resource "aws_apigatewayv2_integration" "intDynamo" {
  api_id           = aws_apigatewayv2_api.gateway.id
  integration_type = "AWS_PROXY"
  connection_type = "INTERNET"
  integration_method = "POST"
  integration_uri =aws_lambda_function.writeToDynamo.invoke_arn
}



resource "aws_apigatewayv2_route" "routeDynamo" {
  api_id    = aws_apigatewayv2_api.gateway.id
  route_key = "POST /addToDynamo"
  target = "integrations/${aws_apigatewayv2_integration.intDynamo.id}"
}




resource "aws_lambda_permission" "allow_lambda_invocation_dynamo" {
  action        = "lambda:InvokeFunction"
  function_name = "${aws_lambda_function.writeToDynamo.arn}"
  principal     = "apigateway.amazonaws.com"
  source_arn    = "${aws_apigatewayv2_api.gateway.execution_arn}/*/*"
  statement_id  = "AllowExecutionFromAPIGateway"
}

resource "aws_iam_role_policy_attachment" "lambda_dynamodb" {
  role       = aws_iam_role.lambda_exec.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonDynamoDBFullAccess"
}

# Create the event mapping between DynamoDB and Lambda

resource "aws_apigatewayv2_stage" "prod" {
  api_id      = aws_apigatewayv2_api.gateway.id
  name        = "prod"
  auto_deploy = true
}

output "api_endpoint" {
    value = aws_apigatewayv2_api.gateway.api_endpoint
}
output "stage_url" {
    value = aws_apigatewayv2_stage.prod.invoke_url
}

# Create an IAM role for the Lambda function
resource "aws_iam_role" "lambda_exec" {
  name = "lambda_exec_role"

  assume_role_policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Sid": "",
      "Effect": "Allow",
      "Principal": {
        "Service": "lambda.amazonaws.com"
      },
      "Action": "sts:AssumeRole"
    }
  ]
}
EOF
}

# Attach policies to the IAM role
resource "aws_iam_role_policy_attachment" "lambda_dynamodb_all" {
  role       = aws_iam_role.lambda_exec.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSLambdaBasicExecutionRole" # Basic execution role policy
}

resource "aws_iam_role_policy" "dynamodb_stream" {
  name = "dynamodb_stream_policy"
  role = aws_iam_role.lambda_exec.id

  policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Action": [
        "dynamodb:DescribeStream",
        "dynamodb:GetRecords",
        "dynamodb:GetShardIterator",
        "dynamodb:ListStreams"
      ],
      "Resource": "arn:aws:dynamodb:eu-west-3:344550609883:table/test2/stream/*"
    }
  ]
}
EOF
}

# Create the S3 bucket
resource "aws_s3_bucket" "s3_for_lambda" {
  bucket = "feyez"
}


# Create the DynamoDB table that Lambda will write to
resource "aws_dynamodb_table" "dynamoDbForLambda" {
  name           = "dynamoDbForLambda"
  billing_mode   = "PAY_PER_REQUEST"
  hash_key       = "id"
  attribute {
    name = "id"
    type = "N"
  }
}

# Create the Lambda function
data "archive_file" "test1ZipFile" {
  type        = "zip"
  source_file = "${path.module}/lambda_code/test1.js"
  output_path = "${path.module}/lambda_code/test1.js.zip"
}

resource "aws_lambda_function" "test1" {
  filename         = data.archive_file.test1ZipFile.output_path
  function_name    = "test1"
  role             = aws_iam_role.lambda_exec.arn
  handler          = "test1.handler"
  runtime          = "nodejs14.x"
  source_code_hash = filebase64sha256(data.archive_file.test1ZipFile.output_path)
  
  environment {
    variables = {}
  }
}

# Create the event mapping between DynamoDB and Lambda
resource "aws_lambda_event_source_mapping" "test1_dynamodb" {
  event_source_arn  = aws_dynamodb_table.jobTable.stream_arn
  function_name     = aws_lambda_function.test1.function_name
  starting_position = "LATEST"
  batch_size        = 1
}

# Add IAM policy for Lambda to write to S3 bucket
resource "aws_iam_role_policy" "s3_write_policy" {
  name   = "s3_write_policy"
  role   = aws_iam_role.lambda_exec.id
  policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Action": "s3:PutObject",
      "Resource": "arn:aws:s3:::feyez/*"
    }
  ]
}
EOF
}
