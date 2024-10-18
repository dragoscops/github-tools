#! /bin/bash

###############################################################################
# Install Self-Hosted GitHub Runner Script
#
# This script installs self-hosted GitHub runners based on specified patterns
# and configurations. It downloads the runner, configures it, and starts the
# runner service.
#
# Usage:
#   DEBUG=1 \
#   bash ./install-self-hosted-runner.sh \
#        --github-repository "https://github.com/your/repo" \
#        --github-token "Your_GithubToken" \
#        --runner-folder-pattern "action-runner-{id}" \
#        --runner-name-pattern "action-runner-{id}" \
#        --runner-labels-pattern "action-runner" \
#        --runner-count 2 \
#        --additional-labels "label1 label2"
#
# Options:
#   --github-repository URL            GitHub repository URL (required)
#   --github-token TOKEN               GitHub token (required)
#   --runner-folder-pattern PATTERN    Runner folder pattern (default: 'action-runner-{id}')
#   --runner-name-pattern PATTERN      Runner name pattern (default: 'action-runner-{id}')
#   --runner-labels-pattern PATTERN    Runner labels pattern (default: 'action-runner')
#   --runner-count NUMBER              Number of runners to install (default: 1)
#   --additional-labels LABELS         Additional labels (space-separated)
#   --help, -h                         Show this help message and exit
#
# Environment Variables:
#   DEBUG                              Set to 1 to enable debug mode
#
# Example:
#   DEBUG=1 bash ./install-self-hosted-runner.sh \
#        --github-repository "https://github.com/your/repo" \
#        --github-token "Your_GithubToken" \
#        --runner-folder-pattern "action-runner-{id}" \
#        --runner-name-pattern "action-runner-{id}" \
#        --runner-labels-pattern "action-runner" \
#        --runner-count 2 \
#        --additional-labels "label1 label2"
###############################################################################

if [ ! -z $DEBUG ]; then
  set -ex
fi

function show_help() {
  local exitCode=${1:-0}

  cat >&2 <<EOF
Usage: bash \$0 [options]

Options:
  --github-repository URL            GitHub repository URL (required)
  --github-token TOKEN               GitHub token (required)
  --runner-folder-pattern PATTERN    Runner folder pattern (default: 'action-runner-{id}')
  --runner-name-pattern PATTERN      Runner name pattern (default: 'action-runner-{id}')
  --runner-labels-pattern PATTERN    Runner labels pattern (default: 'action-runner')
  --runner-count NUMBER              Number of runners to install (default: 1)
  --additional-labels LABELS         Additional labels (space-separated)
  --help, -h                         Show this help message and exit

Environment Variables:
  DEBUG                              Set to 1 to enable debug mode

Example:
  DEBUG=1 bash \$0 --github-repository "https://github.com/your/repo" \\
       --github-token "Your_GithubToken" \\
       --runner-folder-pattern "action-runner-{id}" \\
       --runner-name-pattern "action-runner-{id}" \\
       --runner-labels-pattern "action-runner" \\
       --runner-count 2 \\
       --additional-labels "label1 label2"
EOF
  exit $exitCode
}

function install_deps_linux() {
  source /etc/*-release >/dev/null ||
    ID=$(cat /etc/*-release | egrep "^ID=" | awk -F '"' '{ print $2 }')

  case "$ID" in
  amzn)
    sudo yum update -y
    sudo yum install -y curl dotnet docker jq git --allowerasing
    ;;
  debian | ubuntu)
    sudo apt-get update
    sudo apt-get install -y curl jq build-essential git curl
    curl -fsSL https://get.docker.com -o /tmp/get-docker.sh &&
      sudo bash /tmp/get-docker.sh
    ;;
  *)
    echo "Unsupported distro..."
    exit 254
    ;;
  esac
}

function install_deps_darwin() {
  if test which brew >/dev/null; then
    brew install jq
  fi
}

function download_runner_linux() {
  local runnerUrl=${RUNNER_DOWNLOAD_URL:-https://github.com/actions/runner/releases/download/v2.314.1/actions-runner-linux-x64-2.314.1.tar.gz}
  local runnerSha=${RUNNER_DOWNLOAD_SHA:-6c726a118bbe02cd32e222f890e1e476567bf299353a96886ba75b423c1137b5}
  local runnerTgz="/tmp/action-runner.tar.gz"

  curl -o $runnerTgz -L "$runnerUrl"

  echo "$runnerSha  $runnerTgz" | shasum -a 256 -c ||
    echo "$runnerSha  $runnerTgz" | sha256sum -c
}

function download_runner_darwin() {
  export RUNNER_URL=${RUNNER_URL:-https://github.com/actions/runner/releases/download/v2.314.1/actions-runner-osx-x64-2.314.1.tar.gz}
  export RUNNER_SHA=${RUNNER_SHA:-3faff4667d6d12c41da962580168415d628e3ffba9924b9ac995752087efc921}
  download_runner_linux
}

function install_runner() {
  local runnerTgz="/tmp/action-runner.tar.gz"
  local runnerFolderPattern=${RUNNER_FOLDER_PATTERN:-"action-runner-{id}"}
  local runnerCount=${RUNNER_COUNT:-2}
  local runnerNamePattern=${RUNNER_NAME_PATTERN:-"action-runner-{id}"}
  local runnerLabelsPattern=${RUNNER_LABELS_PATTERN:-"action-runner"}

  for i in $(seq 1 $runnerCount); do
    local runnerFolder=$(echo $runnerFolderPattern | sed "s/{id}/$i/")
    local runnerName=$(echo $runnerNamePattern | sed "s/{id}/$i/")
    local runnerLabels=$(echo $runnerLabelsPattern | sed "s/{id}/$i/")

    runnerLabels="$runnerLabels,$ADDITIONAL_LABELS"
    rm -rf $HOME/$runnerFolder

    mkdir -p $HOME/$runnerFolder
    cd $HOME/$runnerFolder
    tar xzf $runnerTgz -C $HOME/$runnerFolder

    ./config.sh --unattended --url "$GITHUB_REPOSITORY" \
      --token "$GITHUB_TOKEN" --name "$runnerName" --labels $runnerLabels

    # https://docs.github.com/en/actions/hosting-your-own-runners/managing-self-hosted-runners/configuring-the-self-hosted-runner-application-as-a-service?platform=linux
    # https://docs.github.com/en/actions/hosting-your-own-runners/managing-self-hosted-runners/configuring-the-self-hosted-runner-application-as-a-service?platform=mac
    sudo ./svc.sh install
    sudo ./svc.sh start
  done
}

################################################################

GITHUB_REPOSITORY=invalid
GITHUB_TOKEN=invalid
RUNNER_FOLDER_PATTERN="action-runner-{id}"
RUNNER_NAME_PATTERN="action-runner-{id}"
RUNNER_LABELS_PATTERN="action-runner"
RUNNER_COUNT=2
RUNNER_DOWNLOAD_URL=""
RUNNER_DOWNLLOAD_SHA=""

while [[ "$#" -gt 0 ]]; do
  case $1 in
  --github-repository)
    GITHUB_REPOSITORY="$2"
    shift
    ;;
  --github-token)
    GITHUB_TOKEN="$2"
    shift
    ;;
  --runner-folder-pattern)
    RUNNER_FOLDER_PATTERN="$2"
    shift
    ;;
  --runner-name-pattern)
    RUNNER_NAME_PATTERN="$2"
    shift
    ;;
  --runner-labels-pattern)
    RUNNER_LABELS_PATTERN="$2"
    shift
    ;;
  --runner-count)
    RUNNER_COUNT="$2"
    shift
    ;;
  --additional-labels)
    ADDITIONAL_LABELS="$2"
    shift
    ;;
  --runner-download-url)
    RUNNER_DOWNLOAD_URL="$2"
    shift
    ;;
  --runner-download-sha)
    RUNNER_DOWNLOAD_SHA="$2"
    shift
    ;;
  --help | -h)
    show_help
    ;;
  *)
    echo "Unknown parameter passed: $1"
    show_help 1
    ;;
  esac
  shift
done

if ! [[ "$RUNNER_COUNT" =~ ^[0-9]+$ ]]; then
  echo "Error: --runner-count must be a positive integer."
  show_help 2
fi

if [[ "$GITHUB_REPOSITORY" == "invalid" ]]; then
  echo "Invalid Github Repository. Not mentioned."
  show_help 3
fi

if [[ "$GITHUB_TOKEN" == "invalid" ]]; then
  echo "Invalid Github Token. Not mentioned."
  show_help 4
fi

OS=$(uname -s | tr '[:upper:]' '[:lower:]')

HOSTNAME_LABEL=$(hostname | awk -F'.' '{ print $1 }')
ADDITIONAL_LABELS="$ADDITIONAL_LABELS,$HOSTNAME_LABEL"

install_deps=install_deps_$OS
$install_deps

download_runner=download_runner_$OS
$download_runner

install_runner
