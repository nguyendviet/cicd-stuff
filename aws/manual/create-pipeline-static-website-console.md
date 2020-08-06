# Create a pipeline for static sites - Console
1. CodePipeline
    - Choose pipeline settings
        - Create pipeline
        - Name: your pipeline name. "Role name" will be generated automatically.
    - Add source stage
        - Source provider: GitHub
        - Connect to GitHub. Wait a bit.
        - Repository: name of repo
        - Branch: name of branch
    - Add build stage
        - Build provider: AWS CodeBuild
        - Project name: Create project
1. CodeBuild
    - Create build project
        - Project name: name of project
        - Operating system: Ubuntu
        - Runtime(s): Standard
        - Image: standard:4.0
        - Buildspec: Insert build commands. Can switch to editor for easy editing.
        ```bash
        version: 0.2

        phases:
        pre_build:
            commands:
            - aws s3 rm s3://BUCKET_NAME --recursive
        build:
            commands:
            - echo "Simple static site. No build commands needed."
        post_build:
            commands:
            - rm -rf .DS_Store .git .gitignore LICENSE README.md
        artifacts:
        files:
            - '**/*'
        name: $(AWS_REGION)-$(date +%Y-%m-%d)
        ```
    :warning: don't specify `base-directory:` unless there's a `dist` or `build` folder.
1. Back to CodePipeLine
    - Add deploy stage
        - Deploy provider: Amazon S3
        - Bucket: bucket name
        - Select "Extract file before deploy". :warning: Don't specify "Deployment path - optional" as "/" because that won't copy anything from the repo to the bucket.
1. SNS (optional)
    - Create topic
        - Name: name of topic
    - Create subscription
        - Protocol: Email
        - Endpoint: email of approver
    - Note: the approver needs to confirm the subscription in order to get notification.
1. After creating the pipeline, stop the execution and Edit the pipeline to add Manual Approval stage.
    - Add stage
        - Stage name: name of stage. E.g.: ManualApproval
    - Add action group
        - Action name: E.g.:ManualApproval
        - Action provider: Manual Approval
        - SNS topic ARN: ARN of SNS.
        - URL for review: URL to GitHub branch commits
        - Comment: recommended otherwise approver(s) won't know what's the notification is about.



