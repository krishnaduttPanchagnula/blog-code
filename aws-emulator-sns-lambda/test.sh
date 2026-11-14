#!/usr/bin/env bash
# Deploy the stack with Terraform, invoke the function, and check each hop.
set -euo pipefail
cd "$(dirname "$0")"
. ./env.sh

step() { printf '\n==> %s\n' "$*"; }

command -v aws >/dev/null || { echo "AWS CLI v2 is required on PATH" >&2; exit 1; }
curl -sf --cacert "$AWS_CA_BUNDLE" "$AWS_ENDPOINT_URL/__admin/health" >/dev/null \
  || { echo "emulator is not running on $AWS_ENDPOINT_URL" >&2; exit 1; }

step "terraform apply"
terraform -chdir=terraform init -input=false -no-color >/dev/null
terraform -chdir=terraform apply -input=false -auto-approve -no-color

FUNCTION=$(terraform -chdir=terraform output -raw function_name)
TOPIC=$(terraform -chdir=terraform output -raw topic_arn)

step "invoke $FUNCTION with a sample order event"
LOG=$(aws lambda invoke --function-name "$FUNCTION" \
  --cli-binary-format raw-in-base64-out \
  --payload '{"order_id":"A-1001","total":42.50}' \
  --log-type Tail --query LogResult --output text \
  invoke-out.json | base64 -d)
echo "$LOG" | grep -E 'published|^REPORT' || true
echo "response: $(cat invoke-out.json)"

step "assert the publish reached SNS"
MESSAGE_ID=$(python3 -c "
import json
body = json.loads(json.load(open('invoke-out.json'))['body'])
print(body['message_id'])
")
echo "SNS accepted the message: $MESSAGE_ID"

step "inspect the topic and its email subscription"
aws sns get-topic-attributes --topic-arn "$TOPIC" \
  --query 'Attributes.{pending:SubscriptionsPending,confirmed:SubscriptionsConfirmed}' --output json
aws sns list-subscriptions-by-topic --topic-arn "$TOPIC" \
  --query 'Subscriptions[].{protocol:Protocol,endpoint:Endpoint,state:SubscriptionArn}' --output json

PENDING=$(aws sns get-topic-attributes --topic-arn "$TOPIC" \
  --query 'Attributes.SubscriptionsPending' --output text)
test "$PENDING" = "1" || { echo "expected 1 pending email subscription, got $PENDING" >&2; exit 1; }

echo
echo "PASS: lambda executed, published to SNS, SNS holds the email subscription."
echo "NOTE: the subscription stays PendingConfirmation - the emulator mints a"
echo "confirmation token but implements no email delivery, so no confirmation"
echo "email is ever sent and the email leg cannot complete locally."
