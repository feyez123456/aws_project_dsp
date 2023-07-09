
 data "archive_file""LambdaZipFile"{
  type = "zip"
  source_file = "${path.module}/lambda_code/writeToDynamo.js"
  output_path = "${path.module}/lambda_code/writeToDynamo.js.zip"
}
resource "aws_lambda_function" "writeToDynamo" {
  filename         = data.archive_file.LambdaZipFile.output_path
  function_name    = "writeToDynamo"
  role             = "${aws_iam_role.role.arn}"
  handler          = "writeToDynamo.handler"
  runtime          = "nodejs14.x"
  source_code_hash = "${filebase64sha256("${path.module}/lambda_code/writeToDynamo.js.zip")}"
  
  environment {
    variables = {
    }
  }
 
}

