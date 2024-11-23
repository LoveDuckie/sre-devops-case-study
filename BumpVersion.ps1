#!/usr/bin/env pwsh

param (
    [ValidateNotNull()]
    [Parameter(Mandatory = $true, HelpMessage = "The path to the project to bump.")]
    [string]$ProjectPath = ".\LinkExtractor\LinkExtractor", # Default to current directory
    [Parameter(Mandatory = $true, HelpMessage = "Upload the package.")]
    [ValidateNotNull()]
    [switch]$UploadPackage = $false,    # Optional parameter to upload package
    [Parameter(Mandatory = $true, HelpMessage = "The version type.")]
    [ValidateNotNull()]
    [ValidateSet("major", "minor", "patch")]
    [string]$VersionType = "patch",
    [Parameter(Mandatory = $true, HelpMessage = "if this is a dry-run.")]
    [ValidateNotNull()]
    [switch]$DryRun = $false           # Option for dry-run
)

# Convert the path specified to an absolute path
function Convert-ToAbsolutePath {
    param (
        [string]$PathToCheck
    )

    if ([System.IO.Path]::IsPathRooted($PathToCheck)) {
        return $PathToCheck
    } else {
        return (Resolve-Path $PathToCheck)
    }
}

# Validate project directory exists
function Validate-Directory {
    param (
        [string]$DirectoryPath
    )

    if (!(Test-Path $DirectoryPath)) {
        Write-Host "Error: Directory '$DirectoryPath' does not exist." -ForegroundColor Red
        exit 1
    }
}

# Validate .csproj file exists
function Validate-CsprojFile {
    param (
        [string]$CsprojPath
    )

    if (!(Test-Path $CsprojPath)) {
        Write-Host "Error: .csproj file '$CsprojPath' not found." -ForegroundColor Red
        exit 1
    }
}

# Backup the .csproj file
function Backup-CsprojFile {
    param (
        [string]$CsprojPath
    )

    $backupPath = "$CsprojPath.bak"
    Copy-Item -Path $CsprojPath -Destination $backupPath -Force
    Write-Host "Backup created at $backupPath" -ForegroundColor Cyan
}

# Get current version from .csproj file
function Get-CurrentVersion {
    param (
        [string]$CsprojPath
    )

    try {
        $csprojContent = Get-Content $CsprojPath
        $versionLine = $csprojContent | Select-String -Pattern '<Version>'
        if ($versionLine) {
            return [regex]::Match($versionLine, '\d+\.\d+\.\d+').Value
        } else {
            throw "Version tag not found."
        }
    } catch {
        Write-Host "Error reading version from '$CsprojPath': $_" -ForegroundColor Red
        exit 1
    }
}

# Bump semantic version
function Bump-Version {
    param (
        [string]$CurrentVersion,
        [ValidateSet("major", "minor", "patch")]
        [string]$VersionType = "patch"
    )

    $versionParts = $CurrentVersion -split '\.'
    $major = [int]$versionParts[0]
    $minor = [int]$versionParts[1]
    $patch = [int]$versionParts[2]

    switch ($VersionType) {
        "major" {
            $major++
            $minor = 0
            $patch = 0
        }
        "minor" {
            $minor++
            $patch = 0
        }
        "patch" {
            $patch++
        }
    }

    return "$major.$minor.$patch"
}

# Update version in .csproj file
function Update-VersionInCsproj {
    param (
        [string]$CsprojPath,
        [string]$NewVersion
    )

    try {
        $csprojContent = Get-Content $CsprojPath
        $updatedContent = $csprojContent -replace '<Version>\d+\.\d+\.\d+</Version>', "<Version>$NewVersion</Version>"
        if (-not $DryRun) {
            Set-Content $CsprojPath $updatedContent
        }
        Write-Host "Updated version to $NewVersion" -ForegroundColor Green
    } catch {
        Write-Host "Error updating version in '$CsprojPath': $_" -ForegroundColor Red
        exit 1
    }
}

# Validate Git repository
function Validate-Git {
    try {
        git status > $null 2>&1
    } catch {
        Write-Host "Error: Not a Git repository or Git is not installed." -ForegroundColor Red
        exit 1
    }
}

# Commit changes
function Commit-VersionChange {
    param (
        [string]$NewVersion
    )

    if (-not $DryRun) {
        git add .
        git commit -m "Bump version to $NewVersion"
        git push
        Write-Host "Committed version change: $NewVersion" -ForegroundColor Green
    } else {
        Write-Host "Dry run: Skipped Git commit." -ForegroundColor Yellow
    }
}

# Start of script
Write-Host "Starting version bump process..." -ForegroundColor Cyan

$ProjectPath = Convert-ToAbsolutePath -PathToCheck $ProjectPath
Validate-Directory -DirectoryPath $ProjectPath

$csprojPath = "$ProjectPath\LinkExtractor.csproj"
Validate-CsprojFile -CsprojPath $csprojPath
Backup-CsprojFile -CsprojPath $csprojPath

$currentVersion = Get-CurrentVersion -CsprojPath $csprojPath
Write-Host "Current version: $currentVersion" -ForegroundColor Yellow

$newVersion = Bump-Version -CurrentVersion $currentVersion -VersionType $VersionType
Write-Host "New version: $newVersion" -ForegroundColor Yellow

Update-VersionInCsproj -CsprojPath $csprojPath -NewVersion $newVersion

if (-not $DryRun) {
    Validate-Git
    Commit-VersionChange -NewVersion $newVersion
} else {
    Write-Host "Dry run: No changes committed." -ForegroundColor Yellow
}

Write-Host "Version bump process completed." -ForegroundColor Cyan
