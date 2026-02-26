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

## Changelog

### Infrastructure updates

**Lambda runtime**: `nodejs12.x` → `nodejs20.x`
- Node 12 reached end-of-life in April 2022 and is no longer supported by AWS
- Node 20 is the current LTS runtime

**Lambda SES handler** (`lambda/index.js`)
- Migrated from `aws-sdk` v2 to `@aws-sdk/client-ses` v3 — the Node 20 Lambda runtime no longer bundles SDK v2
- Fixed critical bug: on SES error, both the error callback and success callback were fired (missing `else` branch caused fall-through)
- Fixed logging: `console.error` was called on every invocation including successful ones
- Added basic input validation: returns HTTP 400 if `name`, `email`, or `note` fields are missing
- Rewrote as `async/await` — cleaner than nested callbacks

**Terraform syntax** (`main.tf`)
- Fixed `depends_on = ["resource.name"]` → `depends_on = [resource.name]`
- String-quoted references in `depends_on` are a breaking change in Terraform 0.12+ and would cause plan/apply to fail

### CI/CD updates (`deploy.yml`, `plan.yml`)

| Item | Old | New |
|---|---|---|
| `actions/checkout` | `@v1` | `@v4` |
| `actions/setup-node` | `@v1` | `@v4` |
| Node.js version | `9.8.0` (EOL 2018) | `20` |
| Terraform action | `hashicorp/terraform-github-actions@master` (deprecated) | `hashicorp/setup-terraform@v3` |
| Terraform version | `0.11.15` (unsupported) | `1.9.8` |

The deprecated `hashicorp/terraform-github-actions` action has been replaced with `hashicorp/setup-terraform` + native `run: terraform <command>` steps, which is the current HashiCorp-recommended approach.
