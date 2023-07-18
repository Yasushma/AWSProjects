
# Define the provider (e.g., AWS)
provider "aws" {
  access_key = "AKIA5WHU6FVFIYGTT4SN"
  secret_key = "cjq0LkUjtqUK2rSk7IkdUIS6nsUjPF5PIo/2KAvD"
  region = "ap-south-1"
}

variable "region" {
  type    = string
  default = "ap-south-1"  # Replace with your desired region
}

###################################Create the Lambda function
resource "aws_lambda_function" "my_lambda_func" {
  function_name    = "my-lambda-func"
  runtime          = "python3.8"
  handler          = "lambdadb.lambda_handler"
  role             = aws_iam_role.lambda_role.arn
  timeout          = 60
  memory_size      = 128
  filename         = "postlambda.zip"
  source_code_hash = filebase64sha256("postlambda.zip")

}
#we have lambdarole at bottom
resource "aws_lambda_permission" "lambda_dynamodb_permission" {
  statement_id  = "lambda_dynamodb_permission"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.my_lambda_func.arn
  principal     = "dynamodb.amazonaws.com"
  source_arn    = "arn:aws:dynamodb:ap-south-1:941111520586:table/Customerdetails"
}

#lambda[role,policy]  apigateawy[role,policy] ,s3[role,policy] ,dynamodb role[policy]

resource "aws_iam_policy" "lambda_policy" {
  name   = "lambda_policy"
  policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Action": "lambda:InvokeFunction",
      "Resource": "${aws_lambda_function.my_lambda_func.arn}"
    }
  ]
}
EOF
}
resource "aws_lambda_permission" "api_gateway_permission" {
  statement_id  = "AllowAPIGatewayInvoke"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.my_lambda_func.arn
  principal     = "apigateway.amazonaws.com"
  #source_arn    = "arn:aws:execute-api:ap-south-1:941111520586:x2vg6rokr5"
  source_arn =   aws_api_gateway_rest_api.postdetails.execution_arn
}

resource "aws_iam_role_policy_attachment" "lambda_policy_attachment" {
  role       = aws_iam_role.lambda_role.name
  policy_arn = aws_iam_policy.lambda_policy.arn
  
}

###################### API GATEWAY ###################################

resource "aws_api_gateway_rest_api" "postdetails" {
  name        = "postdetails"
  description = "Example API"
}
resource "aws_api_gateway_resource" "postresource" {
  rest_api_id = aws_api_gateway_rest_api.postdetails.id
  parent_id   = aws_api_gateway_rest_api.postdetails.root_resource_id
  path_part   = "postdetails"
}

resource "aws_api_gateway_method" "post_method_request" {
  rest_api_id   = aws_api_gateway_rest_api.postdetails.id
  resource_id   = aws_api_gateway_resource.postresource.id
  http_method   = "POST"
  authorization = "NONE"
}

resource "aws_api_gateway_integration" "post_integration_request" {
  rest_api_id             = aws_api_gateway_rest_api.postdetails.id
  resource_id             = aws_api_gateway_resource.postresource.id
  http_method             = aws_api_gateway_method.post_method_request.http_method
  integration_http_method = "POST"
  type                    = "AWS"
  #uri                     = "arn:aws:apigateway:${var.region}:lambda:path/2015-03-31/functions/${aws_lambda_function.my_lambda_func.arn}/invocations"
  uri                     = aws_lambda_function.my_lambda_func.invoke_arn
  credentials             = aws_iam_role.api_gateway_role.arn
}

resource "aws_api_gateway_method_response" "post_method_response" {
  rest_api_id = aws_api_gateway_rest_api.postdetails.id
  resource_id = aws_api_gateway_resource.postresource.id
  http_method = aws_api_gateway_method.post_method_request.http_method
  status_code = "200"  # Adjust the status code as needed

  response_parameters = {
    "method.response.header.Access-Control-Allow-Origin" = true  # Replace '*' with the allowed origin
  }
  response_models = {
    "application/json" = "Empty"
  }
}
resource "aws_api_gateway_integration_response" "post_integration_response" {
  rest_api_id             = aws_api_gateway_rest_api.postdetails.id
  resource_id             = aws_api_gateway_resource.postresource.id
  http_method             = aws_api_gateway_method.post_method_request.http_method
  status_code             = aws_api_gateway_method_response.post_method_response.status_code  # Adjust the status code as needed
  response_templates      = {
    "application/json" = ""
  }
  
  response_parameters = {
    "method.response.header.Access-Control-Allow-Origin" = "'*'"
  }
}


resource "aws_api_gateway_deployment" "my_api_deployment" {
  
  rest_api_id = aws_api_gateway_rest_api.postdetails.id
  stage_name  = "dev"  # Replace with your desired stage name
  
  depends_on = [
    aws_api_gateway_method.post_method_request
  ]
}

resource "aws_iam_role" "api_gateway_role" {
  name = "api_gateway_role"

  assume_role_policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Principal": {
        "Service": "apigateway.amazonaws.com"
      },
      "Action": "sts:AssumeRole"
    }
  ]
}
EOF
}
resource "aws_iam_policy" "api_gateway_policy" {
  name   = "api_gateway_policy"
  policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Action": "lambda:InvokeFunction",
      "Resource": "${aws_lambda_function.my_lambda_func.arn}"
    }
  ]
}
EOF
}
resource "aws_iam_role_policy_attachment" "api_gateway_policy_attachment" {
  role       = aws_iam_role.api_gateway_role.name
  policy_arn = aws_iam_policy.api_gateway_policy.arn
}
######################S3 bucket###############################

resource "aws_s3_bucket" "justnowbucket" {
  bucket = "justnowbucket" # Replace with your desired bucket name
}

resource "aws_s3_bucket_website_configuration" "justnowbucket_website" {
  bucket = aws_s3_bucket.justnowbucket.id

  index_document {
    suffix = "index.html"
  }
}

resource "aws_s3_bucket_policy" "new_bucket_policy" {
  bucket = aws_s3_bucket.justnowbucket.id

  policy = jsonencode(
{
  "Version": "2012-10-17",
  "Statement": [
    {
      
      "Effect": "Allow",
      "Principal": "*",
      "Action": "s3:GetObject",
      "Resource": "arn:aws:s3:::justnowbucket/*"
    }
   
  ]
})
}

resource "aws_s3_object" "index_html" {
  bucket = aws_s3_bucket.justnowbucket.bucket
  key    = "index.html"
  source = "src/index.html"  # Replace with the actual path to your index.html file
  etag   = filemd5("src/index.html")  # Replace with the actual path to your index.html file
  
  content_type = "text/html"
}

resource "aws_s3_object" "knockout_js" {
  bucket = aws_s3_bucket.justnowbucket.bucket
  key    = "knockout-3.4.2.js"
  source = "src/knockout-3.4.2.js"  # Replace with the actual path to your knockout-3.4.2.js file
  etag   = filemd5("src/knockout-3.4.2.js")  # Replace with the actual path to your knockout-3.4.2.js file
  
}
resource "aws_s3_object" "jquery_js" {
  bucket = aws_s3_bucket.justnowbucket.bucket
  key    = "jquery-3.1.1.min.js"
  source = "src/jquery-3.1.1.min.js"  # Replace with the actual path to your jquery-3.1.1.min.js file
  etag   = filemd5("src/jquery-3.1.1.min.js")  # Replace with the actual path to your jquery-3.1.1.min.js file
 
}

resource "aws_iam_role" "s3role" {
  name = "s3_bucket_role"
  assume_role_policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Sid": "",
      "Effect": "Allow",
      "Principal": {
        "Service": "s3.amazonaws.com"
      },
      "Action": "sts:AssumeRole"
    }
  ]
}
EOF
}

resource "aws_iam_policy" "s3policy" {
  name        = "s3_bucket_policy"
  description = "Policy for accessing S3 bucket"

  policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Sid": "AllowPutBucketPolicy",
      "Effect": "Allow",
      "Action": "s3:PutBucketPolicy",
      "Resource": "arn:aws:s3:::justnowbucket/*"
    }
  ]
}
EOF
}

resource "aws_iam_role_policy_attachment" "s3_bucket_policy_attachment" {
  role       = aws_iam_role.s3role.name
  policy_arn = aws_iam_policy.s3policy.arn
}

resource "aws_s3_bucket_ownership_controls" "justnowbucket" {
  bucket = aws_s3_bucket.justnowbucket.id
  rule {
    object_ownership = "BucketOwnerPreferred"
  }
}

resource "aws_s3_bucket_public_access_block" "justnowbucket" {
  bucket = aws_s3_bucket.justnowbucket.id

  block_public_acls       = false
  block_public_policy     = false
  ignore_public_acls      = false
  restrict_public_buckets = false
}

resource "aws_s3_bucket_acl" "justnowbucket_acl" {
  depends_on = [
    aws_s3_bucket_ownership_controls.justnowbucket,
    aws_s3_bucket_public_access_block.justnowbucket,
  ]

  bucket = aws_s3_bucket.justnowbucket.id
  acl    = "public-read"

}

# Add more aws_s3_bucket_object resources for additional JavaScript files or other files


resource "aws_dynamodb_table" "Customerdetails" {
  name           = "Customerdetails"
  billing_mode   = "PAY_PER_REQUEST"
  hash_key       = "Emailid"

  attribute {
    name = "Emailid"
    type = "S"
  }

  attribute {
    name = "FirstName"
    type = "S"
  }

  attribute {
    name = "LastName"
    type = "S"
  }
  global_secondary_index {
    name               = "FirstNameIndex"
    hash_key           = "FirstName"
    projection_type    = "ALL"
    write_capacity     = 5
    read_capacity      = 5
  }

  global_secondary_index {
    name               = "LastNameIndex"
    hash_key           = "LastName"
    projection_type    = "ALL"
    write_capacity     = 5
    read_capacity      = 5
  }
}

#role already craeted in lambda block
resource "aws_iam_role" "lambda_role" {
  name               = "lambda_role"
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
resource "aws_iam_policy" "dynamodb_policy" {
  name   = "dynamodb_policy"
  description = "policy for accesing dynambodb"
  policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Action": [
        "dynamodb:PutItem"
      ],
      "Resource": "arn:aws:dynamodb:ap-south-1:941111520586:table/Customerdetails"
    }
  ]
}
EOF
}

resource "aws_iam_role_policy_attachment" "lambda_dynamodb_policy" {
  role       = aws_iam_role.lambda_role.name
  policy_arn = aws_iam_policy.dynamodb_policy.arn
}




  

