import boto3
client = boto3.client('sns')

def lambda_handler(event, context):
    response = client.publish(TopicArn='arn:aws:sns:ap-southeast-1:255945442255:yap-mailer',Message="default message")
    print("Message published")
    return(response)