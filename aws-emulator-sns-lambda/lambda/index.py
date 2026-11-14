"""Order notifier: publish each incoming event to the SNS topic."""

import json
import os

import boto3


def handler(event, context):
    topic_arn = os.environ["TOPIC_ARN"]
    sns = boto3.client("sns", region_name=os.environ.get("AWS_REGION", "us-east-1"))

    message = json.dumps({"source": context.function_name, "event": event})
    response = sns.publish(
        TopicArn=topic_arn,
        Subject="order notification"[:100],
        Message=message,
    )
    print(f"published {response['MessageId']} to {topic_arn}")

    return {
        "statusCode": 200,
        "body": json.dumps({"message_id": response["MessageId"], "topic_arn": topic_arn}),
    }
