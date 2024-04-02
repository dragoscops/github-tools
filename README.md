# github-tools

## Install Github Runners

> Except for `GITHUB_TOKEN` AND `GITHUB_REPOSITORY`, all other variables are optional (for specific configs)

```bash
GITHUB_TOKEN=<TOKEN> \
GITHUB_REPOSITORY=https://github.com/dragoscirjan/github-tools \
RUNNER_FOLDER_PATTERN="action-runner-{id}" \
RUNNER_COUNT=2 \
RUNNER_NAME_PATTERN="action-runner-{id}" \
RUNNER_LABELS_PATTERN=github-runner \
bash ./bin/github-tools/install-self-hosted-runner.sh
```

## Uninstall Github Runners

```bash
GITHUB_TOKEN=<TOKEN> \
GITHUB_REPOSITORY=https://github.com/dragoscirjan/github-tools \
RUNNER_FOLDER_PATTERN="action-runner-*" \
bash ./bin/github-tools/uninstall-self-hosted-runner.sh
```
