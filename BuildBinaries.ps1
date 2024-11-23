#!/usr/bin/env pwsh
param (
    [string]$ProjectPath = ".\LinkExtractor\LinkExtractor\LinkExtractor.csproj",     # Default path is current directory, but you can specify the .csproj or .sln file path
    [string]$OutputDirectory = ".\Binaries\LinkExtractor\Release", # Default output directory, can be overridden
    [ValidateSet("Release","Debug")]
    [string]$Configuration = "Release" # Default build configuration, can be set to Debug or other configurations
    [ValidateSet("Any CPU")]
    [string]$Achitecture = "Any CPU" # Default build configuration, can be set to Debug or other configurations
)

# Convert the path specified to absolute
function Convert-ToAbsolutePath {
    param (
        [string]$PathToCheck
    )

    # Check if the path is already absolute
    if ([System.IO.Path]::IsPathRooted($PathToCheck)) {
        # If it's already absolute, return it as is
        return $PathToCheck
    } else {
        # If it's relative, resolve it to an absolute path
        $absolutePath = Resolve-Path $PathToCheck
        return $absolutePath
    }
}

# Function to check if dotnet CLI is installed
function Check-Dotnet {
    $dotnetInstalled = (Get-Command dotnet -ErrorAction SilentlyContinue)
    if (-not $dotnetInstalled) {
        Write-Host "The .NET CLI is not installed. Please install it to proceed." -ForegroundColor Red
        exit 1
    } else {
        Write-Host ".NET CLI is installed." -ForegroundColor Green
    }
}

# Main function to build the project
function Build-Project {
    param (
        [string]$ProjectPath,
        [string]$OutputDirectory,
        [string]$Configuration
    )

    # Ensure the output directory exists
    if (-not (Test-Path $OutputDirectory)) {
        Write-Host "Creating output directory: $OutputDirectory" -ForegroundColor Yellow
        New-Item -ItemType Directory -Force -Path $OutputDirectory | Out-Null
    }

    # Run the dotnet build command
    $buildCommand = "dotnet build `"$ProjectPath`" --configuration $Configuration --output `"$OutputDirectory`""

    Write-Host "Building Project: $ProjectPath" -ForegroundColor Cyan
    Write-Host "Output Path: $OutputDirectory" -ForegroundColor Cyan
    Write-Host "Build Configuration: $Configuration" -ForegroundColor Cyan
    Write-Host "Running: $buildCommand" -ForegroundColor Yellow

    Invoke-Expression $buildCommand

    if ($LASTEXITCODE -eq 0) {
        Write-Host "Build succeeded." -ForegroundColor Green
    } else {
        Write-Host "Build failed." -ForegroundColor Red
        exit 1
    }
}

# Check if .NET CLI is installed
Check-Dotnet

# Convert ProjectPath to absolute if it is not
$ProjectPath = Convert-ToAbsolutePath -PathToCheck $ProjectPath
Write-Host "Resolved Project Path: $ProjectPath" -ForegroundColor Cyan

# Build the project
Build-Project -ProjectPath $ProjectPath -OutputDirectory $OutputDirectory -Configuration $Configuration

Write-Host "Build process completed." -ForegroundColor Cyan
