#!/usr/bin/env pwsh

param (
    [Parameter(HelpMessage="The absolute path to where the Helm chart is located.")]
    [ValidateNotNull()]
    [string]$HelmChartPath,    # Path to the Helm chart
    [ValidateNotNull()]
    [string]$Namespace,        # Custom namespace for deployment
    [ValidateNotNull()]
    [string]$ReleaseName = "my-release" # Optional Helm release name
)

# Function to validate if the provided path exists
function Validate-Path {
    param (
        [string]$PathToCheck
    )

    if (!(Test-Path $PathToCheck)) {
        Write-Host "Error: The specified path '$PathToCheck' does not exist." -ForegroundColor Red
        exit 1
    }
}

# Function to create Kubernetes namespace
function Create-Namespace {
    param (
        [string]$NamespaceName
    )

    # Check if the namespace already exists
    $existingNamespace = kubectl get namespace $NamespaceName -o name 2>$null
    if ($existingNamespace) {
        Write-Host "Namespace '$NamespaceName' already exists." -ForegroundColor Yellow
    } else {
        kubectl create namespace $NamespaceName
        if ($LASTEXITCODE -eq 0) {
            Write-Host "Namespace '$NamespaceName' created successfully." -ForegroundColor Green
        } else {
            Write-Host "Error: Failed to create namespace '$NamespaceName'." -ForegroundColor Red
            exit 1
        }
    }
}

# Function to deploy the Helm chart
function Deploy-HelmChart {
    param (
        [string]$ChartPath,
        [string]$NamespaceName,
        [string]$ReleaseName
    )

    # Deploy the chart
    helm upgrade --install `
        -n $NamespaceName `
        $ReleaseName `
        $ChartPath

    if ($LASTEXITCODE -eq 0) {
        Write-Host "Helm chart deployed successfully to namespace '$NamespaceName'." -ForegroundColor Green
    } else {
        Write-Host "Error: Failed to deploy the Helm chart." -ForegroundColor Red
        exit 1
    }
}

# Validate input parameters
if (-not $HelmChartPath) {
    Write-Host "Error: HelmChartPath is a required parameter." -ForegroundColor Red
    exit 1
}

if (-not $Namespace) {
    Write-Host "Error: Namespace is a required parameter." -ForegroundColor Red
    exit 1
}

# Start of script
Write-Host "Starting Helm chart deployment..." -ForegroundColor Cyan

# Validate the Helm chart path
Validate-Path -PathToCheck $HelmChartPath

# Create the namespace if it doesn't exist
Create-Namespace -NamespaceName $Namespace

# Deploy the Helm chart
Deploy-HelmChart -ChartPath $HelmChartPath -NamespaceName $Namespace -ReleaseName $ReleaseName

Write-Host "Helm chart deployment completed." -ForegroundColor Cyan
