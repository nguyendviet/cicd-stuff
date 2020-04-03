# How to use AWS CLI with MFA

- Recommended by AWS [here](https://aws.amazon.com/premiumsupport/knowledge-center/authenticate-mfa-cli/).
- Similar to [switch role](./switch-role.md):

In a UNIX system, create an `.sh` file (e.g. `mfa-aws.sh`):

```bash
unset AWS_ACCESS_KEY_ID AWS_SECRET_ACCESS_KEY AWS_SESSION_TOKEN
aws_credentials=$(aws sts get-session-token --serial-number YOUR_MFA_DEVICE_ARN --token-code $1)

export AWS_ACCESS_KEY_ID=$(echo $aws_credentials|jq '.Credentials.AccessKeyId'|tr -d '"')
export AWS_SECRET_ACCESS_KEY=$(echo $aws_credentials|jq '.Credentials.SecretAccessKey'|tr -d '"')
export AWS_SESSION_TOKEN=$(echo $aws_credentials|jq '.Credentials.SessionToken'|tr -d '"')
```

- You'll need to install [jq](https://stedolan.github.io/jq/download/).
- The default duration is 12 hours.

Now when you need to use the CLI to get your token and use it:

```bash
$ . ~/PATH_TO_YOUR_FILE/.mfa-aws.sh YOUR_MFA_CODE
```

If you need to switch to your default account, run:

```bash
$ unset AWS_ACCESS_KEY_ID AWS_SECRET_ACCESS_KEY AWS_SESSION_TOKEN
```

You can also use aliases in your `bashrc` (Linux) or `bash_profile` (MacOS) to shorten the commands.
