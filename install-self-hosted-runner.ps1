###############################################################################
# Example to run:
# .\install-runner.ps1 `
#      -GithubRepository "https://github.com/your/repo" `
#      -GithubToken "your_GithubToken" `
#      -RunnerFolderPath "github-runner-{id}-local" `
#      -RunnerNamePattern "github-runner-local-{id}" `
#      -RunnerLabelsPattern "github-runner-local"
###############################################################################

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

$RunnerZipPath = "C:\github-actions-runner-template.zip"
$RunnerPath = "C:\github-actions-runner-template"

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
    Write-Host "Downloading runner template..."
    Invoke-WebRequest -Uri $RunnerDownloadUrl -OutFile $RunnerZipPath

    $fileHash = (Get-FileHash -Path $RunnerZipPath -Algorithm SHA256).Hash.ToUpper()
    if ($fileHash -ne $RunnerDownloadSha.ToUpper()) {
        throw "Computed checksum did not match"
    }

    Write-Host "Extracting runner template..."
    Add-Type -AssemblyName System.IO.Compression.FileSystem
    [System.IO.Compression.ZipFile]::ExtractToDirectory($RunnerZipPath, $RunnerPath)
}

function Remove-Runner-Windows {
    Write-Host "Removing runner tempalte..."
    Remove-Item -Recurse -Force $RunnerZipPath -ErrorAction SilentlyContinue
    Remove-Item -Recurse -Force $RunnerPath -ErrorAction SilentlyContinue
}

function Install-Runner-Windows {
    for ($i = 1; $i -le $RunnerCount; $i++) {
        $runnerFolder = $RunnerFolderPath -replace "{id}", $i
        $runnerName = $RunnerNamePattern -replace "{id}", $i
        $runnerLabels = $RunnerLabelsPattern -replace "{id}", $i

        # $runnerFolder = "${env:HOMEDRIVE}${env:HOMEPATH}\${runnerFolder}"
        $runnerFolder = "C:\actions-runner\${runnerFolder}"

        Remove-Item -Recurse -Force $runnerFolder -ErrorAction SilentlyContinue
        New-Item -Path $runnerFolder -ItemType Directory | Out-Null
        Copy-Item -Path "${RunnerPath}\*" -Destination $runnerFolder -Recurse

        Push-Location $runnerFolder
        Write-Host "Configuring runner #${i}..."
        & .\config.cmd --url $GithubRepository --token $GithubToken --name $runnerName --labels $runnerLabels --runasservice

        # https://docs.github.com/en/actions/hosting-your-own-runners/managing-self-hosted-runners/configuring-the-self-hosted-runner-application-as-a-service?platform=windows
        Start-Service "actions.runner.*"
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
Remove-Runner-Windows
Download-Runner-Windows
Install-Runner-Windows
Remove-Runner-Windows

Write-Host "Runner installation and configuration complete."
