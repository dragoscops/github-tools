# ORAS Setup GitHub Action

> Setup ORAS CLI on GitHub Actions runners seamlessly. Install the ORAS CLI tool only if it doesn't exist or force an upgrade to a specific version as needed.

## Table of Contents

- [ORAS Setup GitHub Action](#oras-setup-github-action)
  - [Table of Contents](#table-of-contents)
  - [Features](#features)
  - [Inputs](#inputs)
    - [Input Details](#input-details)
  - [Outputs](#outputs)
  - [Usage](#usage)
    - [Basic Installation](#basic-installation)
    - [Force Installation or Upgrade](#force-installation-or-upgrade)
    - [Custom Binary Installation](#custom-binary-installation)

## Features

- **Conditional Installation**: Installs ORAS CLI only if it's not already present on the runner.
- **Force Upgrade**: Optionally force the installation or upgrade of ORAS to a specified version.
- **Custom Binary Support**: Install a customized version of ORAS by specifying a custom download URL and checksum.
- **Version Specification**: Easily specify the version of ORAS to install.
- **Secure Installation**: Verifies the integrity of the downloaded binary using SHA256 checksums.

## Inputs

| Input      | Description                                                                        | Required | Default |
| ---------- | ---------------------------------------------------------------------------------- | -------- | ------- |
| `version`  | **Version** of the official ORAS CLI to install.                                   | No       | `1.2.0` |
| `url`      | **URL** of the customized ORAS CLI to install. Required if `checksum` is provided. | No       | `N/A`   |
| `checksum` | **SHA256** checksum of the customized ORAS CLI. Required if `url` is provided.     | No       | `N/A`   |
| `force`    | **Force** installation or upgrade of ORAS even if it is already installed.         | No       | `false` |

### Input Details

- **version**

  - **Description**: Specifies the version of the official ORAS CLI to install.
  - **Type**: `string`
  - **Default**: `1.2.0`
  - **Example**: `1.3.0`

- **url**

  - **Description**: URL of the customized ORAS CLI binary to install. Must be provided alongside `checksum` if used.
  - **Type**: `string`
  - **Default**: `N/A`
  - **Example**: `https://custom-url.com/oras.tar.gz`

- **checksum**

  - **Description**: SHA256 checksum of the customized ORAS CLI binary. Must be provided alongside `url` if used.
  - **Type**: `string`
  - **Default**: `N/A`
  - **Example**: `abc123...`

- **force**
  - **Description**: Determines whether to force the installation or upgrade of ORAS even if it is already present on the runner.
  - **Type**: `boolean`
  - **Default**: `false`
  - **Example**: `true`

## Outputs

| Output           | Description                                                                                           |
| ---------------- | ----------------------------------------------------------------------------------------------------- |
| `oras-installed` | Indicates if ORAS was installed or upgraded during the run. `1` if installed/upgraded, `0` otherwise. |

## Usage

To integrate the `oras-setup` action into your GitHub workflow, use it as a step in your job. Below are various usage scenarios demonstrating how to leverage the action's features.

### Basic Installation

Install ORAS CLI **only if it is not already present** on the runner.

```yaml
jobs:
  build:
    runs-on: ubuntu-latest
    steps:
      - name: Checkout Repository
        uses: actions/checkout@v3

      - name: Setup ORAS
        uses: clbt-5f49f15a/reusable-workflows/.github/actions/oras-setup@main
        with:
          version: "1.2.0" # Optional: defaults to 1.2.0

      - name: Verify ORAS Installation
        run: oras --version
```

### Force Installation or Upgrade

Force the installation or upgrade of ORAS CLI to a specified version, regardless of whether it's already installed.

```yaml
jobs:
  build:
    runs-on: ubuntu-latest
    steps:
      - name: Checkout Repository
        uses: actions/checkout@v3

      - name: Force Setup ORAS
        uses: clbt-5f49f15a/reusable-workflows/.github/actions/oras-setup@main
        with:
          version: "1.3.0"
          force: true

      - name: Verify ORAS Upgrade
        run: oras --version
```

### Custom Binary Installation

Install a customized version of ORAS CLI by specifying a custom download URL and its corresponding SHA256 checksum.

```yaml
jobs:
  build:
    runs-on: ubuntu-latest
    steps:
      - name: Checkout Repository
        uses: actions/checkout@v3

      - name: Setup Custom ORAS
        uses: clbt-5f49f15a/reusable-workflows/.github/actions/oras-setup@main
        with:
          url: "https://custom-url.com/oras_custom_linux_amd64.tar.gz"
          checksum: "abc123def456..."

      - name: Verify Custom ORAS Installation
        run: oras --version
```
