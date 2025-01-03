# Create IAM policy to attach to Lambda execution role to allow access to SNS
resource "aws_iam_policy" "yap_sns_access" {
    name = "yap-sns-publish-access"

    policy = jsonencode({
        Version = "2012-10-17"
        Statement = [
            {
                Action = [
                    "sns:Publish"
                ]
                Effect   = "Allow"
                Resource = aws_sns_topic.yap_topic.arn
      },
    ]
  })
}

resource "aws_iam_policy_attachment" "yap_sns_attach" {
  name = "yap_sns_attach"
  roles = [aws_iam_role.lambda_exec_role.name]
  policy_arn = aws_iam_policy.yap_sns_access.arn
}

# Create Lambda basic execution role
resource "aws_iam_role" "lambda_exec_role" {
 name = "yap-event-notifier-executionrole"
  assume_role_policy = jsonencode({
   Version = "2012-10-17",
   Statement = [
     {
       Action = "sts:AssumeRole",
       Principal = {
         Service = "lambda.amazonaws.com"
       },
       Effect = "Allow"
     }
   ]
 })
}

resource "aws_iam_role_policy_attachment" "lambda_basic_execution" {
 role       = aws_iam_role.lambda_exec_role.name
 policy_arn = "arn:aws:iam::aws:policy/service-role/AWSLambdaBasicExecutionRole"
}

# Create IAM role that enables EventBridge to access and interact with other AWS resources.
resource "aws_iam_role" "scheduler_role" {
  name = "EventBridgeSchedulerRole"

  assume_role_policy = jsonencode({
    "Version" : "2012-10-17",
    "Statement" : [
      {
        "Effect" : "Allow",
        "Principal" : {
          "Service" : "scheduler.amazonaws.com"
        },
        "Action" : "sts:AssumeRole"
      }
    ]
  })

  tags = {
    Name = "EventBridgeSchedulerRole"
  }
}

# Create policy for EventBridge to invoke Lambda
resource "aws_iam_role_policy" "eventbridge_invoke_policy" {
  name = "EventBridgeInvokeLambdaPolicy"
  role = aws_iam_role.scheduler_role.id
  policy = jsonencode({
    "Version" : "2012-10-17",
    "Statement" : [
      {
        "Sid" : "AllowEventBridgeToInvokeLambda",
        "Action" : [
          "lambda:InvokeFunction"
        ],
        "Effect" : "Allow",
        "Resource" : aws_lambda_function.lambda_func.arn
      }
    ]
  })
}