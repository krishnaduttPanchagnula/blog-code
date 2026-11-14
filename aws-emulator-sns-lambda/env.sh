# Connect this shell to the local AWS Emulator. Source it, don't execute it:
#   . ./env.sh
# One emulator endpoint serves every AWS service; the emulator mints a fresh
# access key on each start, so credentials are read from the file it writes.

EMULATOR_HOME="${EMULATOR_HOME:-$HOME/.aws/emulator/9297}"

export AWS_ENDPOINT_URL="https://127.0.0.1:9297"
export AWS_CA_BUNDLE="$EMULATOR_HOME/ca.pem"
# Go/Rust clients (Terraform's AWS provider) don't all read AWS_CA_BUNDLE.
export SSL_CERT_FILE="$EMULATOR_HOME/ca.pem"
export AWS_EC2_METADATA_DISABLED=true
export AWS_REGION="us-east-1"
export AWS_DEFAULT_REGION="us-east-1"
unset AWS_PROFILE AWS_SESSION_TOKEN

AWS_ACCESS_KEY_ID=$(awk -F' = ' '/aws_access_key_id/{print $2}' "$EMULATOR_HOME/emulator_credentials")
AWS_SECRET_ACCESS_KEY=$(awk -F' = ' '/aws_secret_access_key/{print $2}' "$EMULATOR_HOME/emulator_credentials")
export AWS_ACCESS_KEY_ID AWS_SECRET_ACCESS_KEY
