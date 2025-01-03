#Create SNS topic
resource "aws_sns_topic" "yap_topic" {
  name = "yap-mailer"

  tags = {
    name = "yap-mailer"
  }
}

# Create SNS topic subscription
resource "aws_sns_topic_subscription" "sns-email-target" {
  topic_arn = aws_sns_topic.yap_topic.arn
  protocol  = "email"
  endpoint  = "jingyang022@yahoo.com.sg"
}