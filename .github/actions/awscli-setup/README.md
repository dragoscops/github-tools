# AWS CLI Setup GitHub Action

This GitHub Action installs and configures the AWS Command Line Interface (AWS CLI) on GitHub Actions runners. It ensures that the AWS CLI is available for your workflows, allowing seamless interaction with AWS services.

## Features

- Installs or updates to the latest version of AWS CLI v2
- Optionally forces reinstallation or upgrade even if AWS CLI is already installed
- Installs `awsume` for enhanced AWS profile and role management
- Supports both `apt` (Debian/Ubuntu) and `apk` (Alpine) package managers

## Inputs

| Name    | Description                                                        | Required | Default |
| ------- | ------------------------------------------------------------------ | -------- | ------- |
| `force` | Force installation or upgrade even if AWS CLI is already installed | No       | `false` |

## Usage

To use this action in your workflow, add the following step:

```yaml
- name: Setup AWS CLI
  uses: your-username/awscli-setup@v1
```

### Forcing Installation or Upgrade

If you want to force the installation or upgrade of AWS CLI even if it is already installed, set the `force` input to `true`:

```yaml
- name: Setup AWS CLI
  uses: your-username/awscli-setup@v1
  with:
    force: true
```

## Example Workflow

Here's an example of how to use this action in a workflow:

```yaml
name: AWS CLI Example

on:
  push:
    branches: [main]

jobs:
  aws-cli-job:
    runs-on: ubuntu-latest
    steps:
      - name: Checkout Code
        uses: actions/checkout@v3

      - name: Setup AWS CLI
        uses: your-username/awscli-setup@v1
        with:
          force: true # Optional: Force installation

      - name: Configure AWS Credentials
        uses: aws-actions/configure-aws-credentials@v2
        with:
          aws-access-key-id: ${{ secrets.AWS_ACCESS_KEY_ID }}
          aws-secret-access-key: ${{ secrets.AWS_SECRET_ACCESS_KEY }}
          aws-region: us-east-1

      - name: List S3 Buckets
        run: aws s3 ls
```

## Notes

- **AWS Credentials**: Ensure you have set up AWS credentials in your repository secrets. You can use the [Configure AWS Credentials](https://github.com/aws-actions/configure-aws-credentials) action to handle this securely.
- **`awsume` Installation**: This action also installs [`awsume`](https://awsu.me/), a tool that makes switching between AWS profiles and roles easier.
- **Compatibility**: The action supports runners using `apt` (like Ubuntu) and `apk` (like Alpine) package managers.

## License

This project is licensed under the terms of the MIT license. See the [LICENSE](LICENSE) file for details.
