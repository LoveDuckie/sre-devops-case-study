<div align="center">

# sre-devops-case-study

</div>

This repository contains the technical assignment for a company named *[REDACTED]*.

---

## Repository Layout

Below is an overview of the repository structure with a description of each path:

```plaintext
.
├── Binaries
│   └── LinkExtractor
│       └── Release
├── Helm
│   ├── Charts
│   │   └── link-extractor-app-pod
│   └── Values
│       ├── DotNet
│       ├── Falco
│       ├── Python
│       └── Trivy
├── Scripts
│   ├── Bash
│   │   ├── Charts
│   │   ├── Docker
│   │   ├── DotNet
│   │   ├── Part4
│   │   └── Python
│   └── PowerShell
├── Services
│   └── GitLab
│       ├── config
│       ├── data
│       └── logs
└── Solutions
    ├── DotNet
    │   └── LinkExtractor
    └── Python
        └── link-extractor
```

### 📁 Binaries

Contains the built binaries for the .NET version of the `LinkExtractor`.

### 📁 Helm

Contains charts and configuration values for deploying Helm Charts to a single-node Kubernetes cluster (locally, with Docker Desktop.)

### 📁 Scripts

Contains helper scripts for a variety of purposes.

- `Bash`
  - Scripts for automating various operations. These are primarily used.
    - `Charts`
      - Contains helper scripts for linting, packaging, and deploying `helm` charts.
    - `Docker`
      - Contains helper scripts for building and pushing container images.
    - `DotNet`
      - Contains helper scripts for testing, building, packaging, and pushing nuget packages for the .NET application.
    - `Part4`
      - Contains scripts that fulfill the criteria for "part 4" of the case study.
    - `Python`
      - Contains helper scripts for linting, formatting, testing, versioning, and packaging the Python application.
  - `service_*.sh`
    - Scripts for starting and stopping `docker-compose` projects (i.e. GitLab) that can be found under `Services` in this repository, see below.

### 📁 Services

`docker-compose` projects for deploying or installing services required for demonstrative purposes.

### 📁 Solutions

Contains source code for projects targeting either .NET or Python.

---

## Overview

This project solution comprises of several components.

1. The **application**.
2. The **container**.
3. The **deployment**.
4. The **pipelines**.

### The Application

The **application** is a Python project that can be found at the following path.

```plaintext
Solutions/Python/link-extractor
```

#### Tools

- `poetry`
  - Project and dependnecy management.
- `pipx`
  - Installing tools and their dependencies as isolated environments, to mitigate pollution with system-wide installed packages.
- `virtualenv`
  - Creating virtual environments for installing packages to in isolation.
- `pyenv`
  - Managing and installing multiple versions of Python on the same system.

#### Considerations

- The application was developed using the `click` framework for managing and validating command-line application.
- Links scraped from input URLs are processed in parallel where possible.
- The library used for invoking HTTP requests is `aiohttp` which enables us to use `async`/`await` behaviour and `await` scraping tasks that are running concurrently with `asyncio.gather`.
- The project is initialized and managed using a tool called `poetry`.
- The `pyproject.toml` file is compliant with Python Enhance Proposals for project and build tooling (PEP).
- The project uses `unittest` for scaffolding unit tests.

### The Container Image

The **container image** is based off the official base image for Python 3.11.

#### Considerations

- The Dockerfile is structured to leverage multi-stage builds for enhanced caching and performance.
- The Dockerfile takes several parameters including a "`UID`" and "`Version Number`".
- The Python application is packaged in the `build` stage of the Dockerfile, and is later copied to the final stage that doesn't include all the additional tooling required for packaging and distributing the application (i.e. `poetry`).
- The Dockerfile defines a `HEALTHCHECK` to ensure that the Python process is running.

### The Deployment

The **deployment** for this project is achieved using Kubernetes and supporting tools such as `helm` and `helmfile`.

#### Tools

- `helm` is used for defining multiple Kubernetes resource definitions and packaging them into a single deployable entity. They are templated ahead-of-time using the Go templating engine.
- `helmfile` is used for ensuring that all `helm` chart repositories are registered and downloaded ahead-of-time so that we can install additional security scanning services such as `trivy` or `falco`.

#### Considerations

- The `helm` chart for the application contains one resource, which is a singular `Pod` definition for the container image. It uses a `restartPolicy` of "`never`", meaning that once the application runs to completion, it will remain there indefinitely. This is laid out as the requirement for this test.

### The Pipelines

The **pipelines** for this project are described using GitLab Actions workflows, which can be found in this project under `.github`.
