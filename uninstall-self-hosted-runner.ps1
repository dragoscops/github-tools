###############################################################################
# TODO: script hasn't been tested
# Example to run:
# .\uninstall-self-hosted-runner.ps1 `
#      -GithubToken "your_GithubToken" `
#      -RunnerFolderPattern "action-runner-*"s
###############################################################################

param(
  [string]$GithubToken = "invalid",
  [string]$RunnerFolderPattern = "actions-runner-*"
)

if ($env:DEBUG) {
    $VerbosePreference = "Continue"
    $DebugPreference = "Continue"
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

if ($GithubToken -eq "invalid") {
    Write-Host "Invalid Github Token. Not mentioned."
    exit 2
}

Uninstall-Runner

Write-Host "Runner uninstallation complete."
