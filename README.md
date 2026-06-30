# Multi-Environment Web Service with Terraform 

![Terraform](https://img.shields.io/badge/Terraform-v1.5+-623CE4?style=for-the-badge&logo=terraform&logoColor=white) ![Docker](https://img.shields.io/badge/Docker-Provider-2496ED?style=for-the-badge&logo=docker&logoColor=white) 
![Learning](https://img.shields.io/badge/Status-Learning_Project-success?style=for-the-badge)

A small production-shaped Terraform project that provisions a containerized web service across **isolated `dev` and `prod` environments** using a single **reusable module**. It runs entirely on local **Docker** — no cloud account, no credentials, no cost — to try, just clone it and `terraform apply` in under a minute.

## Purpose of this Repo

Built to demonstrate idiomatic Terraform: module composition, environment isolation, `for_each` scaling, input validation, and clean separation of configuration from values.

## Architecture

```
                 ┌─────────────────────────────────────────┐
                 │         modules/web_service/             │
                 │  (reusable: image + network + N nginx    │
                 │   containers, templated landing pages)   │
                 └───────────────┬─────────────┬────────────┘
                                 │             │
                 source = "../../modules/web_service"
                                 │             │
        ┌────────────────────────┘             └────────────────────────┐
        │ environments/dev                       environments/prod       │
        │  • 1 instance (blue)                    • 2 instances (blue,    │
        │  • port 8081                              green) ports 9091-2  │
        │  • restart = "no"                        • restart = "always"  │
        │  • own state file                        • own state file      │
        └────────────────────────────────────────────────────────────────┘
```

Each environment is a separate **root module** with its **own state**, calling the shared child module with different inputs. This mirrors how real teams keep environments isolated while reusing one tested module.

## Repository layout

```
.
├── modules/
│   └── web_service/          # reusable module — the core deliverable
│       ├── versions.tf       # provider requirements + version constraints
│       ├── variables.tf      # typed inputs with validation
│       ├── main.tf           # image, network, containers (for_each, dynamic, lifecycle)
│       ├── outputs.tf        # endpoints, network name, container names
│       └── templates/
│           └── index.html.tpl  # rendered per-instance via templatefile()
├── environments/
│   ├── dev/                  # 1 instance,  isolated state
│   └── prod/                 # 2 instances, isolated state
└── .gitignore
```

## Prerequisites

- [Terraform](https://developer.hashicorp.com/terraform/install) >= 1.5
- [Docker](https://docs.docker.com/get-docker/) running locally

## Usage

```bash
# --- Dev environment ---
cd environments/dev
terraform init        # downloads the docker provider, links the module
terraform validate    # static checks
terraform plan        # preview
terraform apply       # type 'yes'

terraform output      # prints the reachable URL(s)
# open http://localhost:8081

# --- Prod environment (separate state, more instances) ---
cd ../prod
terraform init
terraform apply       # type 'yes'
# open http://localhost:9091 and http://localhost:9092

# --- Tear down ---
terraform destroy     # in each environment dir
```

Try editing `environments/prod/terraform.tfvars` to add another instance, then `terraform plan` — note that `for_each` adds only the new container and leaves the existing ones untouched.

## Terraform concepts demonstrated

| Concept | Where |
|---|---|
| Reusable child module + composition | `modules/web_service`, called from both environments |
| Provider requirements & version constraints (`~>`) | `versions.tf` |
| Typed input variables (`string`, `map(object(...))`) | `modules/web_service/variables.tf` |
| Custom-condition validation (`validation`, `alltrue`, `regex`, `can`) | module variables |
| `postcondition` lifecycle check | `modules/web_service/main.tf` |
| `for_each` over a map (stable, scalable resources) | `docker_container.this` |
| `dynamic` blocks | container labels |
| `locals` + functions (`merge`, `upper`, `templatefile`) | module `main.tf` |
| `lifecycle { create_before_destroy }` | container resource |
| Conditional expressions (`prod ? "always" : "no"`) | container `restart` |
| Output values with `for` expressions | `outputs.tf` |
| Environment isolation via separate backends/state | `environments/{dev,prod}` |
| Variable values via auto-loaded `terraform.tfvars` | each environment |
| `.gitignore` + committed lock file best practice | `.gitignore` |

## Future Scope of this Project:
This project was created for learning, handson and testing purposes only.

- **Remote state:** replace each `backend "local"` with `backend "s3"` (+ native locking) or an HCP Terraform `cloud {}` block to enable team collaboration and state locking.
- **Swap the provider:** because environments only pass inputs to the module, the same pattern adapts to AWS (`aws_instance`/ECS), Azure, or Kubernetes by rewriting just the module internals.
- **CI/CD:** add a GitHub Actions workflow running `terraform fmt -check`, `validate`, and `plan` on pull requests.
- **Policy as code:** enforce tagging/port rules with Sentinel or OPA in HCP Terraform.

## Full Fledged Project

 The full fledged project is in this repo: https://github.com/TechWithHer/aws-multi-env-platform
 
## Snapshots of the Deployed Product

![Screen 1](https://github.com/TechWithHer/Multi-Environment-Web-Service-with-Terraform/blob/50baba8048c1320a610b006e799e2956a9a1ebb7/snaps/1.png)


## Helpful Resources: 

- [Automation Pulse: DevOps + AI](https://www.linkedin.com/newsletters/automation-pulse-devops-ai-7173883868029022208/)
- [Learning Resources of #TechWithHer](https://app.notion.com/p/ayushisingh/Learn-Complete-DevOps-with-TechWithHer-d60df188b81e8221a5570156f5f8b477)
- [Youtube Channel for Explaination](https://www.youtube.com/@TechWithHer)
  
## License

MIT — free to reuse.
