#!/usr/bin/env pwsh
function Convert-ToAbsolutePath {
    param (
        [string]$PathToCheck
    )

    # Check if the path is already absolute
    if ([System.IO.Path]::IsPathRooted($PathToCheck)) {
        # If it's already absolute, return it as is
        return $PathToCheck
    }
    else {
        # If it's relative, resolve it to an absolute path
        $absolutePath = Resolve-Path $PathToCheck
        return $absolutePath
    }
}

$BinaryPath = ".\Binaries\LinkExtractor\Release\LinkExtractor"
$BinaryPath = Convert-ToAbsolutePath -PathToCheck $BinaryPath

# Check if the binary path exists
if (-not (Test-Path $BinaryPath)) {
    Write-Host "The binary '$BinaryPath' does not exist." -ForegroundColor Red
    exit 1
}

# Function to check if Git is installed
function Check-GitInstalled {
    $gitCommand = Get-Command git -ErrorAction SilentlyContinue

    if ($gitCommand) {
        Write-Host "Git is installed." -ForegroundColor Green
    }
    else {
        Write-Host "Git is not installed on this system." -ForegroundColor Red
        exit 1
    }
}

$ToolArguments = @("run", "--task-name Stage1Task")

# Main script
Write-Host "Checking if Git is installed..." -ForegroundColor Yellow
Check-GitInstalled

# Run the binary using Start-Process
Write-Host "Running binary: ""$BinaryPath"" with arguments: ""$ToolArguments""" -ForegroundColor Yellow
$Process = Start-Process -FilePath $BinaryPath -ArgumentList $ToolArguments -Wait -NoNewWindow -PassThru

# Check the exit code
if ($Process.ExitCode -ne 0) {
    Write-Host "The binary exited with a non-zero exit code: ${Process.ExitCode}" -ForegroundColor Red
    exit $Process.ExitCode
}
else {
    Write-Host "The binary ran successfully with exit code 0." -ForegroundColor Green
}