#! /bin/bash
if [ ! -z $DEBUG ]; then
    set -ex
fi

RUNNER_URL="https://github.com/actions/runner/releases/download/v2.314.1/actions-runner-linux-x64-2.314.1.tar.gz"
RUNNER_SHA="6c726a118bbe02cd32e222f890e1e476567bf299353a96886ba75b423c1137b5"

RUNNER_FOLDER_PATTERN="action-runner-{id}"
RUNNER_COUNT=2

GITHUB_REPOSITORY=${GITHUB_REPOSITORY:-invalid}
GITHUB_TOKEN=${GITHUB_TOKEN:-invalid}


OS=linux
uname -a | grep Darwin > /dev/null && OS=darwin


function install_deps_linnux() {
  if test which apt-get > /dev/null; then
    sudo apt-get update
    sudo apt-get install -y curl jq build-essential git
  fi

  if test wich rpm > /dev/null; then
    sudo rpm i ...
  fi
}

function install_deps_darwin() {
  if test which brew > /dev/null; then
    brew install jq
  fi
}

function download_runner_linux() {
    local runnerUrl=${RUNNER_URL:-https://github.com/actions/runner/releases/download/v2.314.1/actions-runner-linux-x64-2.314.1.tar.gz}
    local runnerSha=${RUNNER_SHA:-6c726a118bbe02cd32e222f890e1e476567bf299353a96886ba75b423c1137b5}
    local runnerTgz="/tmp/action-runner.tar.gz"

    curl -o $runnerTgz -L "$runnerUrl"
    
    echo "$runnerSha  $runnerTgz" | shasum -a 256 -c
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

    for i in $(seq 1 $runnerCount); do
        local runnerFolder=$(echo $runnerFolderPattern | sed "s/{id}/$i/")
        mkdir -p $HOME/$runnerFolder

        rm -rf $HOME/$runnerFolder
        cd $HOME/$runnerFolder
        tar xzf $runnerTgz -C $runnerFolder

        echo ./config.sh --url $GITHUB_REPOSITORY --token $GITHUB_TOKEN
    done
}

if [[ "$GITHUB_REPOSITORY" == "invalid" ]]; then
    echo "Invalid Github Repository. Not mentioned."
    exit 1
fi

if [[ "$GITHUB_TOKEN" == "invalid" ]]; then
    echo "Invalid Github Token. Not mentioned."
    exit 2
fi

install_deps=install_deps_$OS
$install_deps

download_runner=download_runner_$OS
$download_runner

install_runner