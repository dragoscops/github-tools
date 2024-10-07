# ORAS Setup GitHub Action

This GitHub Action installs and configures the [ORAS CLI](https://oras.land/) on GitHub Actions runners. ORAS CLI is a command-line interface that allows you to work with OCI artifacts in container registries, enabling you to push and pull artifacts like images, Helm charts, and other content.

## Features

- Installs a specified version of the official ORAS CLI
- Optionally forces reinstallation or upgrade even if ORAS is already installed
- Verifies the checksum of the downloaded binary for security
- Designed for Linux runners

## Inputs

| Name       | Description                                                       | Required | Default |
| ---------- | ----------------------------------------------------------------- | -------- | ------- |
| `version`  | Version of the official ORAS CLI to install                       | No       | `1.2.0` |
| `checksum` | SHA256 of the customized ORAS CLI (required if `url` is provided) | No       |         |
| `force`    | Force installation or upgrade even if ORAS is already installed   | No       | `false` |

## Usage

To use this action in your workflow, add the following step:

```yaml
- name: Setup ORAS CLI
  uses: your-username/oras-setup@v1
```

### Specifying a Version

You can specify the version of ORAS CLI to install by setting the `version` input:

```yaml
- name: Setup ORAS CLI
  uses: your-username/oras-setup@v1
  with:
    version: "1.2.0"
```

### Forcing Installation or Upgrade

If you want to force the installation or upgrade of ORAS even if it is already installed, set the `force` input to `true`:

```yaml
- name: Setup ORAS CLI
  uses: your-username/oras-setup@v1
  with:
    force: true
```

## Example Workflow

Here's an example of how to use this action in a workflow:

```yaml
name: ORAS CLI Example

on:
  push:
    branches: [main]

jobs:
  oras-job:
    runs-on: ubuntu-latest
    steps:
      - name: Checkout Code
        uses: actions/checkout@v3

      - name: Setup ORAS CLI
        uses: your-username/oras-setup@v1
        with:
          version: "1.2.0" # Optional: Specify version
          force: true # Optional: Force installation

      - name: Authenticate to Container Registry
        run: |
          echo "${{ secrets.REGISTRY_PASSWORD }}" | oras login -u "${{ secrets.REGISTRY_USERNAME }}" --password-stdin myregistry.example.com

      - name: Push Artifact to Registry
        run: |
          oras push myregistry.example.com/myartifact:latest ./artifact.tar.gz
```

## Notes

- **Version Selection**: By default, the action installs version `1.2.0` of the ORAS CLI. You can specify a different version using the `version` input.
- **Checksum Verification**: The action verifies the SHA256 checksum of the downloaded binary to ensure integrity and security.
- **Custom Checksum and URL**: If you're installing a customized ORAS CLI binary from a different URL, ensure you provide the `checksum` input for security. (Note: The `url` input is mentioned in the `checksum` description but not defined; make sure to adjust the action if you plan to use a custom URL.)
- **Force Installation**: Use the `force` input to reinstall or upgrade ORAS even if it is already installed on the runner.
- **Linux Runners**: This action is designed for Linux GitHub Actions runners.

## License

This project is licensed under the terms of the MIT license. See the [LICENSE](LICENSE) file for details.
