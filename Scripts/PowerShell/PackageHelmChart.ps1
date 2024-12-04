<#
.SYNOPSIS
    Packages a Helm chart at a specified path.

.DESCRIPTION
    This script uses Helm to package a Helm chart at the specified path. 
    The resulting package is saved in the current directory or an optional output directory.

.PARAMETER ChartPath
    The path to the Helm chart to be packaged.

.PARAMETER OutputDirectory
    (Optional) The directory where the packaged chart will be saved. Defaults to the current directory.

.EXAMPLE
    .\Package-HelmChart.ps1 -ChartPath "C:\charts\mychart"

.EXAMPLE
    .\Package-HelmChart.ps1 -ChartPath "C:\charts\mychart" -OutputDirectory "C:\output"
#>

param (
    [Parameter(Mandatory = $true)]
    [string]$ChartPath,

    [Parameter(Mandatory = $false)]
    [string]$OutputDirectory = (Get-Location).Path
)

# Ensure the Helm CLI is available
if (-not (Get-Command "helm" -ErrorAction SilentlyContinue)) {
    Write-Error "Helm CLI is not installed or not available in the system's PATH."
    exit 1
}

# Verify the chart path exists
if (-not (Test-Path $ChartPath)) {
    Write-Error "The specified ChartPath '$ChartPath' does not exist."
    exit 1
}

# Verify the output directory exists
if (-not (Test-Path $OutputDirectory)) {
    Write-Host "The OutputDirectory '$OutputDirectory' does not exist. Creating it..."
    try {
        New-Item -ItemType Directory -Path $OutputDirectory -Force | Out-Null
    } catch {
        Write-Error "Failed to create the OutputDirectory: $_"
        exit 1
    }
}

# Package the Helm chart
Write-Host "Packaging Helm chart located at: $ChartPath"
Write-Host "Saving package to: $OutputDirectory"

try {
    helm package $ChartPath --destination $OutputDirectory
    if ($LASTEXITCODE -eq 0) {
        Write-Host "Helm chart packaged successfully."
    } else {
        Write-Error "Failed to package the Helm chart. Helm exited with code $LASTEXITCODE."
        exit $LASTEXITCODE
    }
} catch {
    Write-Error "An error occurred while packaging the Helm chart: $_"
    exit 1
}
