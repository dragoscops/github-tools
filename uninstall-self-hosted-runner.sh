#! /bin/bash

###############################################################################
# TODO: refactor script to use arguments instead of env vars
# DEBUG=1 \
# RUNNER_FOLDER_PATTERN="action-runner-*-performance" \ \
# bash ./uninstall-self-hosted-runner.sh
###############################################################################

if [ ! -z $DEBUG ]; then
  set -ex
fi

function show_help() {
  local exitCode=${1:-0}
  cat >&2 <<EOF
Usage: bash $0 [options]

Options:
  --github-token TOKEN            GitHub token (required)
  --runner-folder-pattern PATTERN  Runner folder pattern (default: 'action-runner-*')
  --help, -h                      Show this help message and exit

Environment Variables:
  DEBUG                           Set to 1 to enable debug mode

Example:
  DEBUG=1 bash $0 --github-token "Your_GithubToken" --runner-folder-pattern "action-runner-*-performance"
EOF
  exit 1
}

GITHUB_TOKEN="invalid"
RUNNER_FOLDER_PATTERN="action-runner-*"

while [[ "$#" -gt 0 ]]; do
  case $1 in
  --github-token)
    GITHUB_TOKEN="$2"
    shift
    ;;
  --runner-folder-pattern)
    RUNNER_FOLDER_PATTERN="$2"
    shift
    ;;
  --help | -h)
    show_help
    ;;
  *)
    echo "Unknown parameter passed: $1"
    echo ""
    show_help 1
    ;;
  esac
  shift
done

function uninstall_runner() {
  find $HOME -maxdepth 1 -type d -iname "$RUNNER_FOLDER_PATTERN" | while read runnerFolder; do
    echo "> Uninstalling $runnerFolder"

    cd $runnerFolder

    sudo ./svc.sh stop || true
    sudo ./svc.sh uninstall || true

    ./config.sh remove --token $GITHUB_TOKEN || true

    cd $HOME

    rm -rf $runnerFolder
  done
}

if [[ "$GITHUB_TOKEN" == "invalid" ]]; then
  echo "Invalid Github Token. Not mentioned."
  echo
  exit 2
fi

uninstall_runner
