# Docker Setup GitHub Action

This GitHub Action installs and configures Docker on GitHub Actions runners. It ensures that Docker is available for your workflows, allowing you to build, run, and manage Docker containers seamlessly within your CI/CD pipelines.

## Features

- Installs or updates to the latest version of Docker
- Optionally forces reinstallation or upgrade even if Docker is already installed
- Supports both `apt` (Debian/Ubuntu) and `apk` (Alpine) package managers

## Inputs

| Name    | Description                                                       | Required | Default |
| ------- | ----------------------------------------------------------------- | -------- | ------- |
| `force` | Force installation or upgrade even if Docker is already installed | No       | `false` |

## Usage

To use this action in your workflow, add the following step:

```yaml
- name: Setup Docker
  uses: your-username/docker-setup@v1
```

### Forcing Installation or Upgrade

If you want to force the installation or upgrade of Docker even if it is already installed, set the `force` input to `true`:

```yaml
- name: Setup Docker
  uses: your-username/docker-setup@v1
  with:
    force: true
```

## Example Workflow

Here's an example of how to use this action in a workflow:

```yaml
name: Docker Example

on:
  push:
    branches: [main]

jobs:
  docker-job:
    runs-on: ubuntu-latest
    steps:
      - name: Checkout Code
        uses: actions/checkout@v3

      - name: Setup Docker
        uses: your-username/docker-setup@v1
        with:
          force: true # Optional: Force installation

      - name: Build Docker Image
        run: |
          docker build -t my-image:latest .

      - name: Run Docker Container
        run: |
          docker run --rm my-image:latest
```

## Notes

- **Docker Privileges**: GitHub Actions runners typically have Docker installed and configured with the necessary permissions. This action ensures you have the latest version or can force a reinstall if needed.
- **Compatibility**: The action supports runners using `apt` (like Ubuntu) and `apk` (like Alpine) package managers.
- **`sudo` Permissions**: The action uses `sudo` to install Docker. Ensure that your runner environment allows for `sudo` operations.

## License

This project is licensed under the terms of the MIT license. See the [LICENSE](LICENSE) file for details.
