#!/usr/bin/env pwsh

param (
    [bool]$DockerBuildKit = $true,
    [string]$DockerProjectPath = (Join-Path (Get-Location).Path "projects/website"),
    [string]$DockerComposeFilePath = (Join-Path (Join-Path (Get-Location).Path "projects/website") "docker-compose.yaml"),
    [string]$DockerContainersPath = (Join-Path (Join-Path (Get-Location).Path "projects/website") "containers"),
    [string]$ContainersRoot = (Join-Path (Join-Path (Get-Location).Path "projects/website") "containers")
)

# Set environment variables
$env:DOCKER_BUILDKIT = $DockerBuildKit -eq $true ? 1 : 0
$env:DOCKER_PROJECT_PATH = $DockerProjectPath
$env:DOCKER_PROJECT_COMPOSE_FILEPATH = $DockerComposeFilePath
$env:DOCKER_PROJECT_CONTAINERS_PATH = $DockerContainersPath
$env:CONTAINERS_ROOT = $ContainersRoot

# Check prerequisites
if (-not (Test-Command -CommandName "docker")) {
    Write-Error "Failed: Docker is not installed on this system"
    exit 1
}

if (-not (Test-Command -CommandName "yq")) {
    Write-Error "Failed: Unable to find the command 'yq'"
    exit 1
}

# Load services
$BuildServices = yq ".services | to_entries | map(select(.value.build? != null)) | .[].key" $env:DOCKER_PROJECT_COMPOSE_FILEPATH
if (-not $BuildServices) {
    Write-Error "No container images to build."
    exit 3
}

$BuildArchitectures = @("linux/amd64", "linux/arm64")
$BuildTypes = @("development", "production")
$BuilderName = "link-extractor-builder"

# Ensure builder exists
if (-not (Is-ValidDockerBuilder $BuilderName)) {
    Write-Host "Creating Builder: '$BuilderName'"
    Create-DockerBuilder $BuilderName
}

Push-Location $env:DOCKER_PROJECT_PATH

# Combine architectures for manifest
$ArchsCombined = ($BuildArchitectures -join ",")

$ImagePrefix = "link-extractor"

foreach ($BuildService in $BuildServices) {
    Write-Host "*********************************"
    Write-Host "Building Service: '$BuildService'"
    Write-Host "*********************************"
    Write-Host "↪ Service: $BuildService"
    
    $ServiceDockerfilePath = yq ".services['$BuildService']['build']['dockerfile']" $env:DOCKER_PROJECT_COMPOSE_FILEPATH
    $ServiceDockerfilePathAbs = [Environment]::ExpandEnvironmentVariables($ServiceDockerfilePath)
    Write-Host "$ServiceDockerfilePathAbs"
    
    $ServiceBumpVersionFilePath = Join-Path $env:DOCKER_PROJECT_CONTAINERS_PATH "$BuildService/build/.bumpversion.toml"
    $BuildVersion = yq ".tool.\"bumpversion\".current_version" $ServiceBumpVersionFilePath
    Write-Host "↪ Build Version: $BuildVersion"
    
    if (-not $ServiceDockerfilePath) {
        Write-Error "The Dockerfile for '$BuildService' could not be resolved."
        continue
    }

    $TagPrefix = "$ImagePrefix/$BuildService"

    foreach ($BuildType in $BuildTypes) {
        Write-Host "Building type: '$BuildType'"
        $Tag = "$TagPrefix:$BuildType"
        $TagVersion = "$TagPrefix:$VERSION-$BuildType"

        foreach ($BuildArchitecture in $BuildArchitectures) {
            $TagArch = "$Tag-$($BuildArchitecture -replace '/', '-')"
            Write-Host "↪ Architecture: '$BuildArchitecture'"
            Write-Host "↪ Tag (Architecture): '$TagArch'"

            docker buildx build --builder $BuilderName `
                --platform $BuildArchitecture `
                --load `
                --tag $TagArch `
                --build-arg BUILD_TYPE=$BuildType `
                --build-arg VERSION=$BuildVersion `
                -f $ServiceDockerfilePathAbs $env:DOCKER_PROJECT_PATH
        }
    }
}

Pop-Location
Write-Host "All images built and manifests pushed."
exit 0
