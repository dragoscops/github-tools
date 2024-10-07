# Artefact-Push GitHub Action Documentation

## Overview

The `artefact-push` GitHub Action simplifies the process of pushing artefacts to various repositories and storage services. It supports multiple protocols and tools, allowing you to deploy your artefacts to:

- **Docker Registries** (`docker://`)
- **Helm Repositories** (`helm://`)
- **JFrog Artifactory** (`jfrog://`)
- **OCI Registries with ORAS** (`oci://`)
- **Amazon S3 Buckets** (`s3://`)

This action handles authentication, optional building of artefacts, and provides flexibility through customizable options passed as a JSON object.

---

## Table of Contents

- [Features](#features)
- [Inputs](#inputs)
- [Usage](#usage)
  - [Docker](#docker)
    - [Docker Hub](#pushing-to-docker-hub)
    - [GitHub Container Registry (GHCR)](#pushing-to-github-container-registry-ghcr)
    - [AWS Elastic Container Registry (ECR)](#pushing-to-aws-elastic-container-registry-ecr)
  - [Helm](#helm)
    - [OCI Helm Repository](#pushing-to-an-oci-helm-repository)
    - [HTTP Helm Repository](#pushing-to-an-http-helm-repository)
  - [ORAS](#oras)
    - [OCI Registry with ORAS](#pushing-to-an-oci-registry-with-oras)
    - [AWS ECR with ORAS](#pushing-to-aws-ecr-with-oras)
  - [JFrog Artifactory](#jfrog-artifactory)
  - [Amazon S3](#amazon-s3)
- [Options Input Format](#options-input-format)
- [Notes](#notes)
- [Conclusion](#conclusion)

---

## Features

- **Multi-Protocol Support**: Push artefacts to different services seamlessly.
- **Build Capability**: Optionally build your artefact before pushing.
- **Customizable Options**: Pass additional parameters through a JSON object for advanced configurations.
- **Credential Management**: Securely handles authentication for various services.
- **Dependency Management**: Ensures required tools like `jq`, Docker, Helm, and ORAS are available.

---

## Inputs

### Required Inputs

- `to` (string): Destination URI where the artefact will be pushed.

  - Supported schemes:
    - `docker://` &rarr; Docker push
    - `helm://` &rarr; Helm push
    - `jfrog://` &rarr; Push to JFrog Artifactory
    - `oci://` &rarr; ORAS push
    - `s3://` &rarr; AWS S3 copy

- `artefact` (string): Path to the artefact to be pushed.

- `version` (string): Version of the artefact to be pushed.

### Optional Inputs

- `provider` (string): Service provider (e.g., `aws`, `jfrog`, `minio`).

- `build` (boolean): Whether to also build the artefact before pushing (`true` or `false`).

- `username` (string): Username for authenticating with the destination service.

- `password` (string): Password or token for authenticating with the destination service.

- `options` (string): Additional options as a JSON object for advanced configurations.

---

## Usage

### Docker

#### Pushing to Docker Hub

```yaml
- name: Push Docker Image to Docker Hub
  uses: your-repo/artefact-push@v1
  with:
    to: "docker://docker.io/your-dockerhub-username/your-image-name"
    artefact: "."
    version: "1.0.0"
    build: true
    username: ${{ secrets.DOCKERHUB_USERNAME }}
    password: ${{ secrets.DOCKERHUB_PASSWORD }}
    options: |
      {
        "docker_build": {
          "context": ".",
          "file": "./Dockerfile"
        }
      }
```

#### Pushing to GitHub Container Registry (GHCR)

```yaml
- name: Push Docker Image to GHCR
  uses: your-repo/artefact-push@v1
  with:
    to: "docker://ghcr.io/your-github-username/your-image-name"
    artefact: "."
    version: "1.0.0"
    build: true
    username: ${{ github.actor }}
    password: ${{ secrets.GITHUB_TOKEN }}
    options: |
      {
        "docker_build": {
          "context": ".",
          "file": "./Dockerfile"
        }
      }
```

#### Pushing to AWS Elastic Container Registry (ECR)

```yaml
- name: Push Docker Image to AWS ECR
  uses: your-repo/artefact-push@v1
  with:
    to: "docker://your-aws-account-id.dkr.ecr.region.amazonaws.com/your-image-name"
    artefact: "."
    version: "1.0.0"
    build: true
    options: |
      {
        "aws_credentials": {
          "accesskeyid": "${{ secrets.AWS_ACCESS_KEY_ID }}",
          "secretaccesskey": "${{ secrets.AWS_SECRET_ACCESS_KEY }}",
          "region": "your-aws-region"
        },
        "docker_build": {
          "context": ".",
          "file": "./Dockerfile"
        }
      }
```

---

### Helm

#### Pushing to an OCI Helm Repository

```yaml
- name: Push Helm Chart to OCI Registry
  uses: your-repo/artefact-push@v1
  with:
    to: "helm://oci://your-oci-registry.com/helm-charts"
    artefact: "./chart-directory"
    version: "1.0.0"
    build: true
    username: ${{ secrets.HELM_REGISTRY_USERNAME }}
    password: ${{ secrets.HELM_REGISTRY_PASSWORD }}
```

#### Pushing to an HTTP Helm Repository

```yaml
- name: Push Helm Chart to HTTP Repository
  uses: your-repo/artefact-push@v1
  with:
    to: "helm://https://your-helm-repo.com/charts"
    artefact: "./chart-directory"
    version: "1.0.0"
    build: true
    username: ${{ secrets.HELM_REPO_USERNAME }}
    password: ${{ secrets.HELM_REPO_PASSWORD }}
    options: |
      {
        "helm_args": "--force"
      }
```

**Note**: Pushing to an HTTP Helm repository may require additional plugins like `chartmuseum/helm-push`.

---

### ORAS

#### Pushing to an OCI Registry with ORAS

```yaml
- name: Push Artefact to OCI Registry with ORAS
  uses: your-repo/artefact-push@v1
  with:
    to: "oci://your-oci-registry.com/your-repository"
    artefact: "./path/to/your/artefact.zip"
    version: "1.0.0"
    username: ${{ secrets.ORAS_REGISTRY_USERNAME }}
    password: ${{ secrets.ORAS_REGISTRY_PASSWORD }}
    options: |
      {
        "oras_args": "--verbose"
      }
```

#### Pushing to AWS ECR with ORAS

```yaml
- name: Push Artefact to AWS ECR with ORAS
  uses: your-repo/artefact-push@v1
  with:
    to: "oci://your-aws-account-id.dkr.ecr.region.amazonaws.com/your-repository"
    artefact: "./path/to/your/artefact.zip"
    version: "1.0.0"
    options: |
      {
        "aws_credentials": {
          "accesskeyid": "${{ secrets.AWS_ACCESS_KEY_ID }}",
          "secretaccesskey": "${{ secrets.AWS_SECRET_ACCESS_KEY }}",
          "region": "your-aws-region"
        },
        "oras_args": "--verbose"
      }
```

---

### JFrog Artifactory

```yaml
- name: Push Artefact to JFrog Artifactory
  uses: your-repo/artefact-push@v1
  with:
    to: "jfrog://your-artifactory.com/generic-local"
    artefact: "./path/to/your/artefact.zip"
    version: "1.0.0"
    username: ${{ secrets.JFROG_USERNAME }}
    password: ${{ secrets.JFROG_PASSWORD }}
```

---

### Amazon S3

```yaml
- name: Upload Artefact to Amazon S3
  uses: your-repo/artefact-push@v1
  with:
    to: "s3://your-bucket-name/path"
    artefact: "./path/to/your/artefact.zip"
    version: "1.0.0"
    options: |
      {
        "aws_credentials": {
          "accesskeyid": "${{ secrets.AWS_ACCESS_KEY_ID }}",
          "secretaccesskey": "${{ secrets.AWS_SECRET_ACCESS_KEY }}",
          "region": "your-aws-region"
        },
        "awscli_args": "--acl public-read"
      }
```

---

## Options Input Format

The `options` input allows you to pass additional parameters to customize the action's behavior. It should be a JSON-formatted string. Below is an example of the possible keys and values you can include:

```json
{
  "aws_credentials": {
    "accesskeyid": "your-access-key-id",
    "secretaccesskey": "your-secret-access-key",
    "region": "us-west-2",
    "sessiontoken": "your-session-token"
  },
  "docker_build": {
    "context": ".",
    "file": "./Dockerfile",
    "push": false,
    "tags": "latest"
  },
  "docker_credentials": {
    "registry": "your-registry.com",
    "username": "your-username",
    "password": "your-password"
  },
  "oras_args": "--verbose",
  "awscli_args": "--acl public-read",
  "helm_args": "--force"
}
```

---

## Notes

- **Dependencies**: The action ensures that necessary tools like `jq`, Docker, Helm, and ORAS are installed before they're used.
- **Authentication**: Credentials should be stored securely using GitHub Secrets and passed to the action via inputs.
- **Debugging**: Set the `DEBUG` environment variable to output additional debugging information.
- **Error Handling**: The action will exit with an error message if an invalid scheme is provided or if required credentials are missing.
- **Commented Code**: The action contains commented-out code sections for future development or alternative approaches. These are intentionally left in the code for reference.

---

## Conclusion

The `artefact-push` GitHub Action is a versatile tool that simplifies the deployment of artefacts to various services. By abstracting the complexities of different protocols and authentication methods, it allows developers to focus on building and deploying their applications more efficiently.

**Important**: Always ensure that your credentials and sensitive data are handled securely and are not exposed in logs or code repositories.

For any issues or contributions, please refer to the repository's issue tracker or contribute through pull requests.
