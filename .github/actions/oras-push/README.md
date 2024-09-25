# ORAS Push GitHub Action

> Push artifacts to JFROG, S3, and ECR repositories seamlessly using the ORAS CLI within your GitHub Actions workflows. The action intelligently detects the target repository type based on the provided URI and handles authentication accordingly.

## Table of Contents

- [Features](#features)
- [Inputs](#inputs)
- [Outputs](#outputs)
- [Usage](#usage)
  - [Basic Usage](#basic-usage)
  - [Pushing to JFROG](#pushing-to-jfrog)
  - [Pushing to S3](#pushing-to-s3)
  - [Pushing to ECR](#pushing-to-ecr)
- [Example Workflows](#example-workflows)
- [Contributing](#contributing)
- [License](#license)

## Features

- **Multi-Registry Support**: Push artifacts to JFROG, S3, or ECR based on the URI scheme.
- **Automatic Detection**: Detects the target repository type (jfrog://, s3://, ecr://) and configures authentication accordingly.
- **Secure Authentication**: Handles authentication securely for each repository type.
- **Flexible Configuration**: Supports both default and custom configurations for each target.
- **Bash-Only Implementation**: Uses bash scripts for maximum compatibility and simplicity.

## Inputs

| Input                   | Description                                                                                              | Required | Default |
| ----------------------- | -------------------------------------------------------------------------------------------------------- | -------- | ------- |
| `to`                    | **Destination URI** where the artifact will be pushed. Must start with `jfrog://`, `s3://`, or `ecr://`. | Yes      | N/A     |
| `artifact`              | **Path to the artifact** to be pushed.                                                                   | Yes      | N/A     |
| `jfrog-url`             | **JFROG Artifactory URL** (required if pushing to JFROG).                                                | No       | N/A     |
| `jfrog-user`            | **JFROG Username** (required if pushing to JFROG).                                                       | No       | N/A     |
| `jfrog-pass`            | **JFROG Password or API Key** (required if pushing to JFROG).                                            | No       | N/A     |
| `aws-access-key-id`     | **AWS Access Key ID** (required for S3 and ECR).                                                         | No       | N/A     |
| `aws-secret-access-key` | **AWS Secret Access Key** (required for S3 and ECR).                                                     | No       | N/A     |
| `aws-region`            | **AWS Region** (required for S3 and ECR).                                                                | No       | N/A     |

### Input Details

- **to**

  - **Description**: Specifies the destination URI where the artifact will be pushed. The URI scheme determines the target repository type.
  - **Type**: `string`
  - **Example**:
    - `jfrog://your-jfrog-instance/path/to/repo`
    - `s3://your-s3-bucket/path/to/folder`
    - `ecr://your-ecr-repository`

- **artifact**

  - **Description**: Path to the artifact file that needs to be pushed.
  - **Type**: `string`
  - **Example**: `./build/my-artifact.tar.gz`

- **jfrog-url**

  - **Description**: The URL of your JFrog Artifactory instance.
  - **Type**: `string`
  - **Example**: `https://jfrog.example.com/artifactory`

- **jfrog-user**

  - **Description**: Username for JFrog Artifactory authentication.
  - **Type**: `string`
  - **Example**: `admin`

- **jfrog-pass**

  - **Description**: Password or API key for JFrog Artifactory authentication.
  - **Type**: `string`
  - **Example**: `your-api-key`

- **aws-access-key-id**

  - **Description**: AWS Access Key ID for authenticating with S3 or ECR.
  - **Type**: `string`
  - **Example**: `AKIA...`

- **aws-secret-access-key**

  - **Description**: AWS Secret Access Key for authenticating with S3 or ECR.
  - **Type**: `string`
  - **Example**: `your-secret-access-key`

- **aws-region**
  - **Description**: AWS region where your S3 bucket or ECR repository is located.
  - **Type**: `string`
  - **Example**: `us-east-1`

## Outputs

| Output        | Description                                                                |
| ------------- | -------------------------------------------------------------------------- |
| `push-status` | Indicates if the artifact was successfully pushed. `success` or `failure`. |

## Usage

To integrate the `oras-push` action into your GitHub workflow, use it as a step in your job. Below are various usage scenarios demonstrating how to leverage the action's features.

### Basic Usage

Push an artifact to a specified repository by providing the `to` URI and the path to the artifact.

```yaml
jobs:
  push-artifact:
    runs-on: ubuntu-latest
    steps:
      - name: Checkout Repository
        uses: actions/checkout@v3

      - name: Setup ORAS
        uses: path/to/oras-setup@main
        with:
          version: "1.2.0"

      - name: Push Artifact
        uses: path/to/oras-push@main
        with:
          to: "jfrog://your-jfrog-instance/path/to/repo"
          artifact: "./build/my-artifact.tar.gz"
          jfrog-url: "https://jfrog.example.com/artifactory"
          jfrog-user: ${{ secrets.JFROG_USERNAME }}
          jfrog-pass: ${{ secrets.JFROG_PASSWORD }}
```

### Pushing to JFROG

Ensure you provide the necessary JFrog credentials and specify the `jfrog://` URI scheme.

```yaml
jobs:
  push-to-jfrog:
    runs-on: ubuntu-latest
    steps:
      - name: Checkout Repository
        uses: actions/checkout@v3

      - name: Setup ORAS
        uses: path/to/oras-setup@main
        with:
          version: "1.2.0"

      - name: Push Artifact to JFrog
        uses: path/to/oras-push@main
        with:
          to: "jfrog://jfrog.example.com/artifactory/my-repo"
          artifact: "./build/my-artifact.tar.gz"
          jfrog-url: "https://jfrog.example.com/artifactory"
          jfrog-user: ${{ secrets.JFROG_USERNAME }}
          jfrog-pass: ${{ secrets.JFROG_PASSWORD }}
```

### Pushing to S3

Provide AWS credentials and use the `s3://` URI scheme.

```yaml
jobs:
  push-to-s3:
    runs-on: ubuntu-latest
    steps:
      - name: Checkout Repository
        uses: actions/checkout@v3

      - name: Setup ORAS
        uses: path/to/oras-setup@main
        with:
          version: "1.2.0"

      - name: Push Artifact to S3
        uses: path/to/oras-push@main
        with:
          to: "s3://my-s3-bucket/path/to/folder"
          artifact: "./build/my-artifact.tar.gz"
          aws-access-key-id: ${{ secrets.AWS_ACCESS_KEY_ID }}
          aws-secret-access-key: ${{ secrets.AWS_SECRET_ACCESS_KEY }}
          aws-region: "us-east-1"
```

### Pushing to ECR

Authenticate with AWS and use the `ecr://` URI scheme.

```yaml
jobs:
  push-to-ecr:
    runs-on: ubuntu-latest
    steps:
      - name: Checkout Repository
        uses: actions/checkout@v3

      - name: Setup ORAS
        uses: path/to/oras-setup@main
        with:
          version: "1.2.0"

      - name: Configure AWS Credentials
        uses: aws-actions/configure-aws-credentials@v2
        with:
          aws-access-key-id: ${{ secrets.AWS_ACCESS_KEY_ID }}
          aws-secret-access-key: ${{ secrets.AWS_SECRET_ACCESS_KEY }}
          aws-region: "us-east-1"

      - name: Push Artifact to ECR
        uses: path/to/oras-push@main
        with:
          to: "ecr://my-ecr-repo"
          artifact: "./build/my-artifact.tar.gz"
          aws-access-key-id: ${{ secrets.AWS_ACCESS_KEY_ID }}
          aws-secret-access-key: ${{ secrets.AWS_SECRET_ACCESS_KEY }}
          aws-region: "us-east-1"
```
