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
├── Charts
│   ├── link-extractor-app-job
│   │   ├── charts
│   │   └── templates
│   └── link-extractor-app-pod
│       ├── charts
│       └── templates
├── Scripts
│   ├── Bash
│   │   ├── Charts
│   │   ├── Docker
│   │   ├── DotNet
│   │   └── Python
│   └── PowerShell
├── Services
│   └── GitLab
└── Solutions
    ├── DotNet
    │   └── LinkExtractor
    └── Python
        └── link-extractor
```

---

## Scripts

Automation scripts are provided in `bash` and `pwsh` (PowerShell) formats, tailored for different environments. These scripts simplify tasks such as building, deploying, and managing the repository's components.

---

## Implementation

### Solutions

Two implementations were developed to demonstrate the functionality:

#### .NET (C#)

- Framework: .NET 8.0

#### Python

- **Concurrency:**
  - Utilizes concurrency to scan specified URLs and extract links from rendered pages.
- **Unit Tests:**
  - Comprehensive unit tests are available under the `link_extractor_tests` directory.
- **Linting:**
  - Enforces code quality through automated linting.

##### Requirements

- Poetry
- Python 3.11
- `coverage`
- `unittest`

##### Dependencies

The Python solution relies on the following dependencies:

- `aiohttp`
- `beautifulsoup4`
- `click`
- `rich`
- `rich-click`

---

### Kubernetes

Kubernetes manifests are provided for deploying the solutions in different configurations:

#### Charts

- **link-extractor-app-job**  
  Deploys the workload as a Kubernetes `Job`.  
  - Runs once and terminates after completion.

- **link-extractor-app-pod**  
  Deploys the workload as a standalone Kubernetes `Pod`.  
  - Runs to completion and then halts execution using `tail -f /dev/null`.

---

### Docker

#### .NET (C#)

- Based on the `:alpine` image.
- Built with .NET 8.0.

#### Python

- Configured with security best practices and performance optimizations.

##### Security

- Security scanning is performed using tools like **Trivy** to detect vulnerabilities (CVEs).  
- Root user access is disabled.

##### Optimizations

- Utilizes multi-stage builds for better caching and smaller image sizes.
- Supports Docker BuildKit for efficient caching in CI/CD workflows.

---

### CI/CD Pipelines

The repository includes pipelines for two major CI/CD systems:

#### GitLab CI

GitLab CI configurations are available under the `.gitlab-ci` directory.

#### GitHub Actions

GitHub Actions workflows are defined under `.github/workflows`.

---

This refined README is now clearer, well-structured, and concise. Let me know if further adjustments are needed!
