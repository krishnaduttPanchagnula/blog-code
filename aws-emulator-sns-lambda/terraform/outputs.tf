output "function_name" {
  value = aws_lambda_function.notify.function_name
}

output "topic_arn" {
  value = aws_sns_topic.orders.arn
}

output "subscription_arn" {
  value = aws_sns_topic_subscription.email.id
}

output "notification_email" {
  value = var.notification_email
}
