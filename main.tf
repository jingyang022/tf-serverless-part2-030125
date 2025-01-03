#############################################################
# Lambda Function
#############################################################

# Define an archive_file datasource that creates the lambda archive
data "archive_file" "lambda" {
 type        = "zip"
 #source_file = "hello.py"
 source_dir  = "./package"
 output_path = "lambda_function.zip"
}

resource "aws_lambda_function" "lambda_func" {
 function_name = "yap-event-notifier"
 role          = aws_iam_role.lambda_exec_role.arn
 handler       = "lambda_function.lambda_handler"
 runtime       = "python3.8"
 filename      = data.archive_file.lambda.output_path

  # Environment Variables
  /* environment {
    variables = {
       	DDB_TABLE = "yap-topmovies"
    }
  } */
}

# aws_cloudwatch_log_group to get the logs of the Lambda execution.
resource "aws_cloudwatch_log_group" "lambda_log_group" {
 name              = "/aws/lambda/yap-event-notifier"
 retention_in_days = 14
}

#############################################################
# EventBridge Scheduler
#############################################################
resource "aws_scheduler_schedule" "every2minutes" {
  name       = "yap-every-2mins"
  description = "Fires every two minutes"
  #group_name = "default"
  schedule_expression = "rate(2 minutes)"

  flexible_time_window {
    mode = "OFF"
  }  

  target {
    arn      = aws_lambda_function.lambda_func.arn
    role_arn = aws_iam_role.scheduler_role.arn 
  }
}