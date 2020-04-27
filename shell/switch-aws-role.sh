# Script to switch to an AWS role. You'll need to install jq: https://stedolan.github.io/jq/

unset AWS_ACCESS_KEY_ID AWS_SECRET_ACCESS_KEY AWS_SESSION_TOKEN
aws_credentials=$(aws sts assume-role --role-arn arn:aws:iam::YOUR_ACCOUNT_ID:role/admin --role-session-name YOUR_SESSION_NAME --serial-number YOUR_DEVICE_ARN --token-code $1 --duration-seconds YOUR_DURATION)

export AWS_ACCESS_KEY_ID=$(echo $aws_credentials|jq '.Credentials.AccessKeyId'|tr -d '"')
export AWS_SECRET_ACCESS_KEY=$(echo $aws_credentials|jq '.Credentials.SecretAccessKey'|tr -d '"')
export AWS_SESSION_TOKEN=$(echo $aws_credentials|jq '.Credentials.SessionToken'|tr -d '"')

# Then you use an alias in your .bash_profile (MacOS) or .bashrc (Ubuntu) to execute this file to switch role for your AWS CLI:
# .bash_profile example:
# alias use-some-role=". ~/.aws/switch-some-role.sh"
