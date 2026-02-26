# Changelog

Entries are ordered newest first. Format: `## [YYYY-MM-DD] — summary`.

## [2026-02-26] — Infrastructure & CI/CD overhaul

### Lambda runtime: `nodejs12.x` → `nodejs20.x`
- Node 12 reached end-of-life in April 2022 and is no longer supported by AWS
- Node 20 is the current LTS runtime

### Lambda SES handler (`lambda/index.js`)
- Migrated from `aws-sdk` v2 to `@aws-sdk/client-ses` v3 — the Node 20 Lambda runtime no longer bundles SDK v2
- Fixed critical bug: on SES error, both the error callback and success callback were fired (missing `else` branch caused fall-through)
- Fixed logging: `console.error` was called on every invocation including successful ones
- Added basic input validation: returns HTTP 400 if `name`, `email`, or `note` fields are missing
- Rewrote as `async/await` — cleaner than nested callbacks

### Terraform syntax (`main.tf`)
- Fixed `depends_on = ["resource.name"]` → `depends_on = [resource.name]`
- String-quoted references in `depends_on` are a breaking change in Terraform 0.12+ and would cause plan/apply to fail

## CI/CD updates (`deploy.yml`, `plan.yml`)

| Item | Old | New |
|---|---|---|
| `actions/checkout` | `@v1` | `@v4` |
| `actions/setup-node` | `@v1` | `@v4` |
| Node.js version | `9.8.0` (EOL 2018) | `20` |
| Terraform action | `hashicorp/terraform-github-actions@master` (deprecated) | `hashicorp/setup-terraform@v3` |
| Terraform version | `0.11.15` (unsupported) | `1.9.8` |

The deprecated `hashicorp/terraform-github-actions` action has been replaced with `hashicorp/setup-terraform` + native `run: terraform <command>` steps, which is the current HashiCorp-recommended approach.
