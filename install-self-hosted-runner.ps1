param(
    [string]$GITHUB_REPOSITORY = "invalid",
    [string]$GITHUB_TOKEN = "invalid"
)

if ($DEBUG) {
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
    $runnerUrl = ${env:RUNNER_URL} -or "https://github.com/actions/runner/releases/download/v2.317.0/actions-runner-win-x64-2.317.0.zip"
    $runnerSha = ${env:RUNNER_SHA} -or "a74dcd1612476eaf4b11c15b3db5a43a4f459c1d3c1807f8148aeb9530d69826"
    $runnerZip = "C:\actions-runner\actions-runner-win-x64-2.317.0.zip"

    Write-Host "Downloading runner..."
    Invoke-WebRequest -Uri $runnerUrl -OutFile $runnerZip

    $fileHash = (Get-FileHash -Path $runnerZip -Algorithm SHA256).Hash.ToUpper()
    if ($fileHash -ne $runnerSha.ToUpper()) {
        throw "Computed checksum did not match"
    }

    Write-Host "Extracting runner..."
    Add-Type -AssemblyName System.IO.Compression.FileSystem
    [System.IO.Compression.ZipFile]::ExtractToDirectory($runnerZip, "C:\actions-runner")
}

function Install-Runner-Windows {
    $runnerFolderPattern = ${env:RUNNER_FOLDER_PATTERN} -or "C:\actions-runner\action-runner-{id}"
    $runnerCount = [int](${env:RUNNER_COUNT} -or 2)
    $runnerNamePattern = ${env:RUNNER_NAME_PATTERN} -or "action-runner-{id}"
    $runnerLabelsPattern = ${env:RUNNER_LABELS_PATTERN} -or "action-runner"

    for ($i = 1; $i -le $runnerCount; $i++) {
        $runnerFolder = $runnerFolderPattern -replace "{id}", $i
        $runnerName = $runnerNamePattern -replace "{id}", $i
        $runnerLabels = $runnerLabelsPattern -replace "{id}", $i

        Remove-Item -Recurse -Force $runnerFolder -ErrorAction SilentlyContinue
        New-Item -Path $runnerFolder -ItemType Directory | Out-Null
        Copy-Item -Path "C:\actions-runner\*" -Destination $runnerFolder

        Push-Location $runnerFolder
        Write-Host "Configuring runner..."
        & .\config.cmd --unattended --url $GITHUB_REPOSITORY --token $GITHUB_TOKEN --name $runnerName --labels $runnerLabels

        Write-Host "Installing runner as service..."
        & .\svc.cmd install
        & .\svc.cmd start
        Pop-Location
    }
}

if ($GITHUB_REPOSITORY -eq "invalid") {
    Write-Host "Invalid Github Repository. Not mentioned."
    exit 1
}

if ($GITHUB_TOKEN -eq "invalid") {
    Write-Host "Invalid Github Token. Not mentioned."
    exit 2
}

Install-Dependencies-Windows
Download-Runner-Windows
Install-Runner-Windows

Write-Host "Runner installation and configuration complete."
