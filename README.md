<div align="center">

# sre-devops-case-study

</div>

The base repository for the technical assignment for the company named *[REDACTED]*.

## Layout

Find below the repository of the layout, along with descriptions of each path.

```shell
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

## Scripts

Scripts have been defined for automating various processes within this repository. They are defined as `bash` and `pwsh` (PowerShell) scripts, depending on the environment you are using this repository with.

## Implementation

Find below details regarding implementation.


### Solutions

Find below the two solutiosn that were developed for demonstrating this functionality.

#### .NET (C#)

- Uses .NET 8.0

#### Python

- **Concurrency:**
  - Uses concurrency for scanning specified URLs for available links on rendered pages.
- **Unit Tests:**
  - Includes unit tests under `link_extractor_tests`.
- **Linting:**
  - Includes unit tests under `link_extractor_tests`.

##### Requirements

- Poetry
- Python 3.11
- `coverage`
- `unittest`

##### Dependencies

Find below the list of dependencies for the project.

- `aiohttp`
- `beautifulsoup4`
- `click`
- `rich`
- `rich-click`

---

### Kubernetes

Find below some of the information regarding the implementation and deployment to Kubernetes.

#### Charts

Find below a couple of charts that were developed, and the rationales behind them.

- **link-extractor-app-job**
  - Deploys the container workload as a Kubernetes `job`.
  - This runs once and terminates.
- **link-extractor-app-pod**
  - Deploys the container workload as a Kubernetes `pod`.
  - This runs to completion and then halts execution by using `tail -f /dev/null`.

---

### Docker

Find below details regarding implementations for container images.

#### .NET (C#)

- `:alpine` base container image.
- .NET 8.0

#### Python


#### Security

- Security scanning tools like Trivy for generating reports for CVE notices.
- Root user is disabled.

#### Optimizations

- Multi-stage cached builds.
- Docker BuildKit with cached builders for repeat usage with CI workers or runners.

### CI

Find below details about the implementations for either CI system used for this demonstration.

#### GitLab CI

The GitLab CI pipelines can be found in this repository under `.gitlab-ci`.

#### GitHub Actions

The GitHub Actions workflows can be found this reposiotry under `.github/workflows`.