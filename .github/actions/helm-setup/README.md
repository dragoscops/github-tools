# Helm Setup GitHub Action

This GitHub Action installs and configures [Helm](https://helm.sh/) on Linux GitHub Actions runners. It ensures that Helm is available for your workflows, allowing you to manage Kubernetes applications efficiently.

## Features

- Installs or upgrades to the latest version of Helm 3
- Optionally forces reinstallation or upgrade even if Helm is already installed
- Installs the `helm-push` plugin for pushing charts to ChartMuseum
- Outputs whether Helm was installed or upgraded
- Designed for Linux runners

## Inputs

| Name    | Description                        | Required | Default |
| ------- | ---------------------------------- | -------- | ------- |
| `force` | Force installation/upgrade of Helm | No       | `false` |

## Outputs

| Name             | Description                                                             |
| ---------------- | ----------------------------------------------------------------------- |
| `helm-installed` | Indicates if Helm was installed or upgraded (`1` if installed/upgraded) |

## Usage

To use this action in your workflow, add the following step:

```yaml
- name: Setup Helm
  uses: your-username/helm-setup@v1
```

### Forcing Installation or Upgrade

If you want to force the installation or upgrade of Helm even if it is already installed, set the `force` input to `true`:

```yaml
- name: Setup Helm
  uses: your-username/helm-setup@v1
  with:
    force: true
```

## Example Workflow

Here's an example of how to use this action in a workflow:

```yaml
name: Helm Example

on:
  push:
    branches: [main]

jobs:
  helm-job:
    runs-on: ubuntu-latest
    steps:
      - name: Checkout Code
        uses: actions/checkout@v3

      - name: Setup Helm
        id: helm-setup
        uses: your-username/helm-setup@v1
        with:
          force: true # Optional: Force installation

      - name: Initialize Kubernetes Cluster (Kind)
        uses: engineerd/setup-kind@v0.5.0

      - name: Deploy Chart
        run: |
          helm repo add stable https://charts.helm.sh/stable
          helm install my-release stable/nginx-ingress

      - name: List Helm Releases
        run: helm list

      - name: Check if Helm was Installed
        if: steps.helm-setup.outputs.helm-installed == '1'
        run: echo "Helm was installed or upgraded."
```

## Notes

- **Helm Version**: This action installs the latest version of Helm 3 using the official installation script.
- **Helm Plugins**: The action also installs the [`helm-push`](https://github.com/chartmuseum/helm-push) plugin, which allows you to push charts to ChartMuseum.
- **Output Variable**: You can use the `helm-installed` output to determine if Helm was installed or upgraded during the action.

  ```yaml
  - name: Setup Helm
    id: helm-setup
    uses: your-username/helm-setup@v1

  - name: Conditional Step
    if: steps.helm-setup.outputs.helm-installed == '1'
    run: echo "Helm was installed or upgraded."
  ```

- **Linux Runners**: This action is designed for Linux GitHub Actions runners.

## License

This project is licensed under the terms of the MIT license. See the [LICENSE](LICENSE) file for details.
