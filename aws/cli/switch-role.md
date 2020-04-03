## Switch role to use other AWS accounts with MFA

> Note: Make sure you have all the access you need for this manual.

Set up the role (`YOUR_ROLE`) in the `YOUR_SECOND_ACCOUNT` [AWS Docs](https://docs.aws.amazon.com/IAM/latest/UserGuide/tutorial_cross-account-with-roles.html).

The Trust Relationship of the `YOUR_SECOND_ACCOUNT` `YOUR_ROLE` role:

```json
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Principal": {
        "AWS": "arn:aws:iam::YOUR_FIRST_ACCOUNT_ID:root"
      },
      "Action": "sts:AssumeRole",
      "Condition": {
        "Bool": {
          "aws:MultiFactorAuthPresent": "true"
        }
      }
    }
  ]
}
```

In this case, in order to assume the role `YOUR_ROLE` of the `YOUR_SECOND_ACCOUNT`, `YOUR_FIRST_ACCOUNT` users must provide MFA code.

```json
"Condition": {
    "Bool": {
        "aws:MultiFactorAuthPresent": "true"
    }
}
```

*If the Trust Relationship doesn't have any `Condition`, then you don't need to provide MFA code.*

Policy in the `YOUR_FIRST_ACCOUNT` that allows users to assume `YOUR_SECOND_ACCOUNT` `YOUR_ROLE` role:

```json
{
  "Version": "2012-10-17",
  "Statement": {
    "Effect": "Allow",
    "Action": "sts:AssumeRole",
    "Resource": "arn:aws:iam::YOUR_SECOND_ACCOUNT_ID:role/YOUR_ROLE"
  }
}
```

In a UNIX system, create an `.sh` file (e.g. `switch-to-YOUR_ROLE.sh`):

```bash
unset AWS_ACCESS_KEY_ID AWS_SECRET_ACCESS_KEY AWS_SESSION_TOKEN
aws_credentials=$(aws sts assume-role --role-arn arn:aws:iam::YOUR_SECOND_ACCOUNT_ID:role/YOUR_ROLE --role-session-name YOUR_SESSION_NAME --serial-number YOUR_MFA_ARN --token-code $1 --duration-seconds YOUR_DURATION_IN_SECONDS)

export AWS_ACCESS_KEY_ID=$(echo $aws_credentials|jq '.Credentials.AccessKeyId'|tr -d '"')
export AWS_SECRET_ACCESS_KEY=$(echo $aws_credentials|jq '.Credentials.SecretAccessKey'|tr -d '"')
export AWS_SESSION_TOKEN=$(echo $aws_credentials|jq '.Credentials.SessionToken'|tr -d '"')
```

- You'll need to install [jq](https://stedolan.github.io/jq/download/).
- You need to set up the `Maximum CLI/API session duration` in your `YOUR_SECOND_ACCOUNT` role `YOUR_ROLE` to match `YOUR_DURATION_IN_SECONDS`.

Now when you need to use the CLI to access services in the `YOUR_SECOND_ACCOUNT` using the `YOUR_ROLE` role, run this:

```bash
$ . ~/PATH_TO_YOUR_FILE/switch-to-YOUR_ROLE.sh YOUR_MFA_CODE
```

If you need to switch to your default account, run:

```bash
$ unset AWS_ACCESS_KEY_ID AWS_SECRET_ACCESS_KEY AWS_SESSION_TOKEN
```

You can also use aliases in your `bashrc` (Linux) or `bash_profile` (MacOS) to shorten the commands.
