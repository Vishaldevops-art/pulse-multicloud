# pulse-multicloud

One containerized service (**pulse-api**) deployed to **Azure AKS** and **AWS EKS** with **Terraform**, a **GitHub Actions** pipeline
(OIDC, no stored cloud keys), **remote state with locking**, and **Prometheus/Grafana** monitoring.

> Status: 🚧 in progress — built step by step over 8 weeks. See the checklist at the bottom.

## Architecture (target)

```
                GitHub Actions (OIDC)
       test → build → Trivy scan → push → terraform plan/apply → helm deploy
                 │                                │
        ┌────────┴────────┐              ┌────────┴────────┐
        ▼                 ▼              ▼                 ▼
   Azure: ACR ──► AKS (Helm: pulse-api)  AWS: ECR ──► EKS (Helm: pulse-api)
        VNet, NSG, Ingress-nginx              VPC, SGs, ALB (LB Controller)
        state: Storage Account (lease lock)   state: S3 (native lockfile)
                 │                                │
                 └──────── Prometheus + Grafana ──┘
```

## Layout

| Path | What |
|---|---|
| `app/` | FastAPI service: `/`, `/health`, `/ready`, `/metrics`. Multi-stage, non-root Dockerfile. |
| `helm/pulse-api/` | Helm chart: Deployment (probes, securityContext, zero-downtime rollout), Service, optional Ingress + HPA |
| `terraform/bootstrap/{azure,aws}` | One-time remote-state backends |
| `terraform/modules/` | Network + cluster modules per cloud (specs in `modules/README.md`) |
| `terraform/envs/{azure,aws}` | Environment roots that call the modules |
| `.github/workflows/ci.yml` | Test, Terraform fmt/validate, build, scan, push |

## Run locally

```bash
cd app
docker build -t pulse-api:dev .
docker run --rm -p 8080:8080 pulse-api:dev
# http://localhost:8080/  /health  /metrics
```

On kind:

```bash
kind create cluster --name pulse
kind load docker-image pulse-api:dev --name pulse
helm upgrade --install pulse helm/pulse-api
kubectl port-forward svc/pulse 8080:80
```

## Cloud deploys — rules

1. `terraform plan` and read it before every `apply`.
2. `terraform destroy` at the end of every lab session. Check the console for leftover load balancers, disks and public IPs.
3. Credentials come from `az login` / `aws configure sso` (locally) and OIDC (in CI). No keys in code or Git.

## Progress

- [x] App + Dockerfile + tests
- [x] Helm chart
- [x] Remote-state bootstrap code (Azure + AWS)
- [x] CI: test, build, scan, push
- [ ] Azure network + AKS modules, deployed and destroyed
- [ ] AWS network + EKS modules, deployed and destroyed
- [ ] OIDC from GitHub Actions to both clouds; terraform plan on PRs
- [ ] CD with approval gate to both clusters
- [ ] Prometheus + Grafana dashboard, SLOs, alert rules
- [ ] checkov / Trivy IaC scanning in PRs
- [ ] Screenshots + 3-min demo video
