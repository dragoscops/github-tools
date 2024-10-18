###############################################################################
# Uninstall Self-Hosted GitHub Runner Script
#
# This script uninstalls self-hosted GitHub runners based on a specified folder
# pattern. It stops and removes the runner services and deletes the runner folders.
#
# Usage:
#   $env:DEBUG=1
#   .\uninstall-self-hosted-runner.ps1 `
#        -GithubToken "Your_GithubToken" `
#        -RunnerFolderPattern "actions-runner-*"
#
# Options:
#   -GithubToken TOKEN            GitHub token (required)
#   -RunnerFolderPattern PATTERN  Runner folder pattern (default: 'actions-runner-*')
#   -Help, -H                     Show this help message and exit
#
# Environment Variables:
#   DEBUG                         Set to 1 to enable debug mode
#
# Example:
#   $env:DEBUG=1; .\uninstall-self-hosted-runner.ps1 -GithubToken "Your_GithubToken" -RunnerFolderPattern "actions-runner-*"
###############################################################################

param(
  [string]$GithubToken = "invalid",
  [string]$RunnerFolderPattern = "actions-runner-*",
  [switch]$Help = $false,
  [switch]$H = $false
)

if ($env:DEBUG) {
    $VerbosePreference = "Continue"
    $DebugPreference = "Continue"
}

function Show-Help {
  param (
    [int]$ExitCode = 0
  )
  $helpMessage = @"
Usage: .\uninstall-self-hosted-runner.ps1 [options]

Options:
  -GithubToken TOKEN            GitHub token (required)
  -RunnerFolderPattern PATTERN  Runner folder pattern (default: 'actions-runner-*')
  -Help, -H                     Show this help message and exit

Environment Variables:
  DEBUG                         Set to 1 to enable debug mode

Example:
  $env:DEBUG=1; .\uninstall-self-hosted-runner.ps1 -GithubToken "Your_GithubToken" -RunnerFolderPattern "actions-runner-*"

"@
  # Write the help message to stderr
  [Console]::Error.WriteLine($helpMessage)
  exit $exitCode
}

function Uninstall-Runner {
    $runnerFolders = Get-ChildItem -Path C:/actions-runner -Directory -Filter $RunnerFolderPattern

    foreach ($runnerFolder in $runnerFolders) {
        Write-Host "> Uninstalling $($runnerFolder.FullName)"

        Set-Location -Path $runnerFolder.FullName

        # Remove-Service "actions.runner.*"

        try {
            Write-Host "Removing configuration..."
            Start-Process -FilePath "./config.cmd" -ArgumentList "remove", "--token", $GithubToken -Wait -NoNewWindow -ErrorAction Stop
        } catch {
            Write-Host "Failed to remove configuration, continuing..." -ForegroundColor Yellow
        }

        Set-Location -Path "C:/"
        Remove-Item -Recurse -Force -Path $runnerFolder.FullName

        Write-Host "Uninstalled $($runnerFolder.FullName)"
    }
}

if ($Help -or $H) {
    Show-Help
}

if ($GithubToken -eq "invalid") {
    Write-Host "Invalid Github Token. Not mentioned."
    Show-Help -ExitCode 1
}

Uninstall-Runner

Write-Host "Runner uninstallation complete."
