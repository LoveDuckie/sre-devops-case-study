<div align="center">

# SRE DevOps Case Study

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

---

## Case Study

Find below the responses to the case study questions

### Part 1: Create a program

I created an application using Python and .NET with C#, however, I decided to finalise the solution with Python.

#### Sample


#### Usage

You can run the application by invoking the following scripts and parameters.

```bash
Scripts/Bash/Python/python/python_run_pipx.sh -p Solutions/Python/link-extractor -u https://news.bbc.co.uk -o json
```

This script will install the Python package using `pipx` in a temporary virtual environment, run the script with the supplied parameters, and then return the resulting exit code.


### Part 2: Package as Docker image

- The `Dockerfile` is defined under `Solutions/Python/link-extractor`.
- The project Docker image can be built using the script `Scripts/Bash/Docker/build_docker.sh`. This will build it for multiple architectures.
- The project Docker container image is built using Docker BuildKit backend (`docker buildx build`).

### Part 3: Deploy to Kubernetes

#### Requirements

- Docker Desktop with Kubernetes enabled.
  - **NOTE:** Tested on macOS *only.*
- `helm`
  - For deploying described resources required by a Kubernetes resource.
- `helmfile`
  - Deploying multiple `helm` charts at the same time.
  - Registers multiple chart repositories.
  - Installs `helm` charts described in the `helmfile.yaml`.
- `k9s`
  - An interactive terminal application for observing and diagnosing issue with deployed Kubernetes