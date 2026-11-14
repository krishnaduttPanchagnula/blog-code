variable "emulator_endpoint" {
  description = "AWS Emulator endpoint (one emulator serves every service)."
  type        = string
  default     = "https://127.0.0.1:9297"
}

variable "aws_region" {
  description = "Region to address the emulator with; it serves a single region."
  type        = string
  default     = "us-east-1"
}

variable "notification_email" {
  description = "Address subscribed to the topic over the email protocol."
  type        = string
  default     = "dev-team@example.com"
}
