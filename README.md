# be-personal-site

Infrastructure and CI/CD for [alexandermorton.co.uk](https://alexandermorton.co.uk).

Deploys the frontend static assets (via git submodule) to S3, serves them through CloudFront with Lambda@Edge, and exposes a contact-form API via API Gateway + SES Lambda.

## Stack

- **IaC**: Terraform 1.9.x
- **Cloud**: AWS (S3, CloudFront, Lambda, API Gateway, Route53, ACM, SES)
- **CI/CD**: GitHub Actions
- **Submodules**: `fe-personal-site`, `cloudfrontEdge-s3-module`

## Architecture

```
User → Route53 → CloudFront → Lambda@Edge (originRequest / originResponse)
                            → S3 (static assets)

Contact form → API Gateway → SES Lambda → AWS SES → alex@alexandermorton.co.uk
```

## Deployment

Deployment is fully automated via GitHub Actions:

- **Push to `master`** — runs `terraform plan` only (no changes applied)
- **Push a `v*` tag** — runs full deploy: build frontend → terraform apply → S3 sync → CloudFront invalidation

### Terraform state backend

| Resource | Value |
|---|---|
| S3 bucket | `wgl-site-terraform-state` |
| DynamoDB table | `wgl-site-terraform-state` |
| Region | `eu-west-2` |

### Required GitHub secrets

| Secret | Purpose |
|---|---|
| `AWS_ACCESS_KEY_ID` | AWS credentials for Terraform + S3 + CloudFront |
| `AWS_SECRET_ACCESS_KEY` | AWS credentials |
| `GITHUB_REPO_TOKEN` | Checkout submodules (needs `repo` scope) |
| `PERSONAL_SITE_CF_ID` | CloudFront distribution ID for cache invalidation |

See [CHANGELOG.md](CHANGELOG.md) for version history.
