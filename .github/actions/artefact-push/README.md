# Artefact Push GitHub Action

Push artefacts to various repositories such as Docker registries, Helm repositories, AWS S3, OCI-compliant registries, and JFrog artifactory using tools like Docker CLI, Helm, ORAS, and AWS CLI.

## Description

The `artefact-push` GitHub Action allows you to push artefacts to different types of repositories seamlessly. Depending on the destination URI scheme provided, it intelligently selects the appropriate tool and method to upload your artefact.

## Supported Schemes

- `docker://` - Push to Docker registries
- `helm://` - Push Helm charts
- `jfrog://` - Push to JFrog artifactory
- `oci://` - Push using ORAS CLI to OCI-compliant registries
- `s3://` - Upload to AWS S3 buckets

## Inputs

| Name       | Description                                                                                                                                                                      | Required |
| ---------- | -------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- | -------- |
| `to`       | **Required.** Destination URI where the artefact will be pushed. The URI should start with one of the supported schemes (`docker://`, `helm://`, `jfrog://`, `oci://`, `s3://`). | `true`   |
| `artefact` | **Required.** Path to the artefact to be pushed.                                                                                                                                 | `true`   |
| `build`    | Whether to build the artefact before pushing.                                                                                                                                    | `false`  |
| `version`  | **Required.** Version of the artefact to be pushed.                                                                                                                              | `true`   |
| `username` | Username for service authentication (if required).                                                                                                                               | `false`  |
| `password` | Password or token for service authentication (if required).                                                                                                                      | `false`  |
| `options`  | Additional options as a JSON object.                                                                                                                                             | `false`  |

## Usage Examples

### 1. Pushing Docker Images (`docker://`)

#### Pushing to Docker Hub (`docker.io`)

```yaml
- name: Build and Push Docker Image to Docker Hub
  uses: your-org/artefact-push@v1
  with:
    to: "docker://docker.io/your-docker-username/your-image-name"
    artefact: "your-image-name"
    version: "1.0.0"
    username: ${{ secrets.DOCKER_USERNAME }}
    password: ${{ secrets.DOCKER_PASSWORD }}
    build: true
```

**Note:** Replace `your-docker-username` and `your-image-name` with your Docker Hub username and image name respectively.

#### Pushing to GitHub Container Registry (`ghcr.io`)

```yaml
- name: Build and Push Docker Image to GHCR
  uses: your-org/artefact-push@v1
  with:
    to: "docker://ghcr.io/your-org/your-image-name"
    artefact: "your-image-name"
    version: "1.0.0"
    username: ${{ github.actor }}
    password: ${{ secrets.GITHUB_TOKEN }}
```

**Note:** GHCR supports authentication using the `GITHUB_TOKEN`. Ensure you set `username` to `${{ github.actor }}` and `password` to `${{ secrets.GITHUB_TOKEN }}`.

#### Pushing to JFrog artifactory

```yaml
- name: Build and Push Docker Image to JFrog artifactory
  uses: your-org/artefact-push@v1
  with:
    to: "docker://artifactory.example.com/docker-local/your-image-name"
    artefact: "your-image-name"
    version: "1.0.0"
    username: ${{ secrets.JFROG_USERNAME }}
    password: ${{ secrets.JFROG_PASSWORD }}
```

**Note:** Ensure that the Docker repository (`docker-local`) is configured in JFrog artifactory.

#### Pushing to AWS Elastic Container Registry (ECR)

```yaml
- name: Build and Push Docker Image to AWS ECR
  uses: your-org/artefact-push@v1
  with:
    to: "docker://your-account-id.dkr.ecr.your-region.amazonaws.com/your-repo"
    artefact: "your-image-name"
    version: "1.0.0"
    options: |
      {
        "aws_credentials": {
          "AccessKeyId": "${{ secrets.AWS_ACCESS_KEY_ID }}",
          "SecretAccessKey": "${{ secrets.AWS_SECRET_ACCESS_KEY }}",
          "SessionToken": "${{ secrets.AWS_SESSION_TOKEN }}",
          "Region": "${{ secrets.AWS_REGION }}",
        },
      }
```

**Note:** The action will automatically handle AWS authentication for ECR, but it's limited to the values above.
Ensure AWS credentials are set up using `aws-actions/configure-aws-credentials`.

### 2. Pushing Helm Charts (`helm://`)

#### Pushing to JFrog artifactory

```yaml
- name: Package and Push Helm Chart to JFrog artifactory
  uses: your-org/artefact-push@v1
  with:
    to: "helm://oci://artifactory.example.com/helm-local"
    artefact: "./charts/your-chart"
    version: "1.0.0"
    username: ${{ secrets.JFROG_USERNAME }}
    password: ${{ secrets.JFROG_PASSWORD }}
```

**Note:** The Helm repository (`helm-local`) should be set up in JFrog artifactory.

#### Pushing to an OCI-compliant Registry (e.g., Azure Container Registry)

```yaml
- name: Package and Push Helm Chart to Azure Container Registry
  uses: your-org/artefact-push@v1
  with:
    to: "helm://oci://yourregistry.azurecr.io/helm-repo"
    artefact: "./charts/your-chart"
    version: "1.0.0"
    username: ${{ secrets.ACR_USERNAME }}
    password: ${{ secrets.ACR_PASSWORD }}
    build: true
```

#### Pushing to an HTTP Helm Repository

```yaml
- name: Package and Push Helm Chart to HTTP Helm Repository
  uses: your-org/artefact-push@v1
  with:
    to: "helm://https://your-helm-repo.com/charts"
    artefact: "./charts/your-chart"
    version: "1.0.0"
    username: ${{ secrets.HELM_REPO_USERNAME }}
    password: ${{ secrets.HELM_REPO_PASSWORD }}
    build: true
```

### 3. Uploading to AWS S3 (`s3://`)

#### Example: Uploading a File to an S3 Bucket

```yaml
- name: Push artefact to AWS S3
  uses: your-org/artefact-push@v1
  with:
    to: "s3://your-s3-bucket-name"
    artefact: "path/to/your-artefact.zip"
    version: "1.0.0"
    options: |
      {
        "awscli_args": "--acl public-read"
      }
```

**Note:** Ensure that your AWS credentials are configured in the environment, typically via `aws-actions/configure-aws-credentials`.

### 4. Pushing artefacts Using ORAS (`oci://`)

#### Pushing to GitHub Packages

```yaml
- name: Push artefact using ORAS to GitHub Packages
  uses: your-org/artefact-push@v1
  with:
    to: "oci://ghcr.io/your-org/your-package"
    artefact: "path/to/your-artefact.zip"
    version: "1.0.0"
    username: ${{ github.actor }}
    password: ${{ secrets.GITHUB_TOKEN }}
    options: |
      {
        "oras_args": "--manifest-config config.json:application/vnd.unknown.config.v1+json"
      }
```

#### Pushing to an OCI-compliant Registry (e.g., Harbor)

```yaml
- name: Push artefact using ORAS to Harbor Registry
  uses: your-org/artefact-push@v1
  with:
    to: "oci://harbor.your-domain.com/your-project/your-repo"
    artefact: "path/to/your-artefact.zip"
    version: "1.0.0"
    username: ${{ secrets.HARBOR_USERNAME }}
    password: ${{ secrets.HARBOR_PASSWORD }}
    options: |
      {
        "oras_args": "--manifest-config config.json:application/vnd.unknown.config.v1+json"
      }
```

#### Pushing to AWS Elastic Container Registry (ECR)

```yaml
- name: Push artefact using ORAS to Harbor Registry
  uses: your-org/artefact-push@v1
  with:
    to: "oci://your-account-id.dkr.ecr.your-region.amazonaws.com/your-repo"
    artefact: "path/to/your-artefact.zip"
    version: "1.0.0"
    options: |
      {
        "aws_credentials": {
          "AccessKeyId": "${{ secrets.AWS_ACCESS_KEY_ID }}",
          "SecretAccessKey": "${{ secrets.AWS_SECRET_ACCESS_KEY }}",
          "SessionToken": "${{ secrets.AWS_SESSION_TOKEN }}",
          "Region": "${{ secrets.AWS_REGION }}",
        },
        "oras_args": "--manifest-config config.json:application/vnd.unknown.config.v1+json"
      }
```

### 5. Pushing artefacts to JFrog artifactory (`jfrog://`)

#### Example: Uploading an artefact to JFrog artifactory

```yaml
- name: Push artefact to JFrog artifactory
  uses: your-org/artefact-push@v1
  with:
    to: "jfrog://artifactory.example.com/generic-local"
    artefact: "path/to/your-artefact.zip"
    version: "1.0.0"
    username: ${{ secrets.JFROG_USERNAME }}
    password: ${{ secrets.JFROG_PASSWORD }}
```

**Note:** This example uploads a generic artefact to a JFrog artifactory repository named `generic-local`.

## Additional Notes

- **Authentication:** Depending on the destination, you might need to provide `username` and `password`. These can be set using GitHub secrets.
- **Building artefacts:** If your artefact needs to be built before pushing (e.g., Docker images or Helm charts), set `build: true`.
- **Options:** Use the `options` input to pass additional arguments to the underlying CLI tools. Provide these as a JSON object.
- **AWS Credentials:** When working with AWS services like S3 or ECR, ensure that AWS credentials are properly configured using `aws-actions/configure-aws-credentials`.

## Troubleshooting

- **Invalid Scheme:** Ensure the `to` input starts with one of the supported schemes.
- **Authentication Errors:** Verify that the correct `username` and `password` are provided and that they have the necessary permissions.
- **artefact Path Issues:** Ensure the `artefact` path is correct relative to your repository root.
- **Permissions:** Ensure that the account used has the necessary permissions to push artefacts to the target repository.

## License

This project is licensed under the [MIT License](LICENSE).

```

```
