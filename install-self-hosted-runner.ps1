param(
    [string]$GithubRepository = "invalid",
    [string]$GithubToken = "invalid",
    [int]$RunnerCount = 2,
    [string]$RunnerFolderPath = "action-runner-{id}",
    [string]$RunnerNamePattern = "action-runner-{id}",
    [string]$RunnerLabelsPattern = "action-runner",
    [string]$RunnerDownloadUrl = "https://github.com/actions/runner/releases/download/v2.317.0/actions-runner-win-x64-2.317.0.zip",
    [string]$RunnerDownloadSha = "a74dcd1612476eaf4b11c15b3db5a43a4f459c1d3c1807f8148aeb9530d69826"
)

$RunnerZipPath = "C:\github-actions-runner-installer.zip"

###############################################################################
# Example to run:
# .\install-runner.ps1 -GithubRepository "https://github.com/your/repo" -GithubToken "your_GithubToken" `
#                       -RunnerFolderPath "github-runner-{id}-system-tests" `
#                       -RunnerNamePattern "github-runner-system-tests-{id}" `
#                       -RunnerLabelsPattern "github-runner-system-tests"
###############################################################################

if ($env:DEBUG) {
    $VerbosePreference = "Continue"
    $DebugPreference = "Continue"
}

$OS = (Get-CimInstance -ClassName Win32_OperatingSystem).Caption

function Install-Dependencies-Windows {
    Write-Host "Installing dependencies on Windows..."
    # Chocolatey installation
    if (-not (Get-Command choco -ErrorAction SilentlyContinue)) {
        Set-ExecutionPolicy Bypass -Scope Process -Force
        [System.Net.ServicePointManager]::SecurityProtocol = [System.Net.ServicePointManager]::SecurityProtocol -bor 3072
        Invoke-Expression ((New-Object System.Net.WebClient).DownloadString('https://chocolatey.org/install.ps1'))
    }
    choco install git -y
    choco install jq -y
}

function Download-Runner-Windows {
    $RunnerDownloadSha = ${env:RUNNER_SHA} -or "a74dcd1612476eaf4b11c15b3db5a43a4f459c1d3c1807f8148aeb9530d69826"

    Write-Host "Downloading runner..."
    Invoke-WebRequest -Uri $RunnerDownloadUrl -OutFile $RunnerZipPath

    $fileHash = (Get-FileHash -Path $RunnerZipPath -Algorithm SHA256).Hash.ToUpper()
    if ($fileHash -ne $RunnerDownloadSha.ToUpper()) {
        throw "Computed checksum did not match"
    }

    Write-Host "Extracting runner..."
    Add-Type -AssemblyName System.IO.Compression.FileSystem
    [System.IO.Compression.ZipFile]::ExtractToDirectory($RunnerZipPath, "C:\actions-runner")
}

function Install-Runner-Windows {
    for ($i = 1; $i -le $RunnerCount; $i++) {
        $runnerFolder = $RunnerFolderPath -replace "{id}", $i
        $runnerName = $RunnerNamePattern -replace "{id}", $i
        $runnerLabels = $RunnerLabelsPattern -replace "{id}", $i

        Remove-Item -Recurse -Force $runnerFolder -ErrorAction SilentlyContinue
        New-Item -Path $runnerFolder -ItemType Directory | Out-Null
        Copy-Item -Path "C:\actions-runner\*" -Destination $runnerFolder

        Push-Location $runnerFolder
        Write-Host "Configuring runner..."
        & .\config.cmd --unattended --url $GithubRepository --token $GithubToken --name $runnerName --labels $runnerLabels

        Write-Host "Installing runner as service..."
        & .\svc.cmd install
        & .\svc.cmd start
        Pop-Location
    }
}

if ($GithubRepository -eq "invalid") {
    Write-Host "Invalid Github Repository. Not mentioned."
    exit 1
}

if ($GithubToken -eq "invalid") {
    Write-Host "Invalid Github Token. Not mentioned."
    exit 2
}

Install-Dependencies-Windows
Download-Runner-Windows
# Install-Runner-Windows

# Write-Host "Runner installation and configuration complete."
