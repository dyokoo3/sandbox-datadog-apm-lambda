data "archive_file" "lambda_hello_world" {
  type = "zip"

  source_dir  = "${path.module}/lambda/hello-world"
  output_path = "${path.module}/lambda/hello-world.zip"
}

resource "aws_s3_bucket" "lambda_bucket" {
  bucket = "${local.service}-${local.env}-lambda-bucket"
}

resource "aws_s3_bucket_acl" "lambda_bucket" {
  bucket = aws_s3_bucket.lambda_bucket.id
  acl    = "private"
}

resource "aws_s3_object" "lambda_hello_world" {
  bucket = aws_s3_bucket.lambda_bucket.id

  key    = "hello-world.zip"
  source = data.archive_file.lambda_hello_world.output_path

  etag = filemd5(data.archive_file.lambda_hello_world.output_path)
}

resource "aws_lambda_function" "hello_world" {
  function_name = "${local.service}-${local.env}-hello-world"

  s3_bucket = aws_s3_bucket.lambda_bucket.id
  s3_key    = aws_s3_object.lambda_hello_world.key

  runtime = "nodejs12.x"
  handler = "/opt/nodejs/node_modules/datadog-lambda-js/handler.handler"

  layers = ["arn:aws:lambda:ap-northeast-1:464622532012:layer:Datadog-Node12-x:77"]

  source_code_hash = data.archive_file.lambda_hello_world.output_base64sha256

  role = aws_iam_role.lambda_exec.arn

  environment {
    variables = {
      DD_LAMBDA_HANDLER = "hello.handler"
      DD_TRACE_ENABLED  = "true"
      DD_FLUSH_TO_LOG   = "true"
    }
  }

  tags = {
    service = local.service
    env     = local.env
  }
}

resource "aws_cloudwatch_log_group" "hello_world" {
  name = "/aws/lambda/${aws_lambda_function.hello_world.function_name}"

  retention_in_days = 1
}

resource "aws_iam_role" "lambda_exec" {
  name = "${local.service}-${local.env}-serverless-lambda"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Action = "sts:AssumeRole"
      Effect = "Allow"
      Sid    = ""
      Principal = {
        Service = "lambda.amazonaws.com"
      }
      }
    ]
  })
}

resource "aws_iam_role_policy_attachment" "lambda_policy" {
  role       = aws_iam_role.lambda_exec.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSLambdaBasicExecutionRole"
}
