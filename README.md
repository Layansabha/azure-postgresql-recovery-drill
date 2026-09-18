# Azure PostgreSQL Recovery Drill

Controlled data loss -> Point-in-Time Restore -> programmatic validation -> measured recovery.

## Engineering problem

Having backups enabled does not prove that recovery actually works.

This project performs a controlled logical data-loss incident against Azure Database for PostgreSQL Flexible Server, restores the database to a known point before the incident, restores required network access, validates the recovered data programmatically, and measures the observed recovery.

## Tested recovery flow

Known 10-row PostgreSQL dataset
-> baseline validation PASS
-> controlled DELETE
-> source database reduced to 0 rows
-> validation FAIL / exit code 3
-> Azure Point-in-Time Restore
-> new restored PostgreSQL Flexible Server
-> restored-server firewall rule recreated
-> TCP and PostgreSQL connectivity verified
-> same deterministic validation script executed
-> validation PASS / exit code 0
-> source remained at 0 rows while restored server contained 10 rows

## Observed result

One tested lab run produced:

| Metric | Observed result |
|---|---:|
| Selected recovery-point gap | 16.70 minutes |
| PITR initiation to restored server Ready | 7.06 minutes |
| Ready to validated recovery | 7.02 minutes |
| End-to-end observed recovery duration | 14.08 minutes |

These are observations from one controlled lab run.

They are not guaranteed RTO/RPO values and are not Azure SLA claims.

## Infrastructure

- Azure region: UAE North
- Azure Database for PostgreSQL Flexible Server
- PostgreSQL 17
- Standard_B1ms
- 32 GiB storage
- 7-day backup retention
- High Availability disabled
- Geo-redundant backup disabled
- Public network access enabled
- Firewall restricted to one current client public IPv4

## Recovery dataset

Expected `orders` baseline:

- Row count: 10
- Total amount: 1230.75
- Minimum order ID: 1001
- Maximum order ID: 1010
- Exact expected dataset comparison required

Before the incident, validation returned PASS.

After the controlled deletion, validation returned FAIL with process exit code 3.

After PITR, the same validation returned PASS with process exit code 0.

## Important Azure recovery behavior

Point-in-Time Restore creates a new PostgreSQL Flexible Server rather than rolling the damaged source server backward.

The restored server did not inherit the source server firewall rule.

The recovery procedure therefore explicitly:

1. waited for the restored server to become Ready,
2. verified the firewall rule was absent,
3. created a new firewall rule for the current client public IPv4,
4. verified TCP port 5432 connectivity,
5. authenticated using `psql`,
6. ran programmatic data validation.

## Repository structure

- `terraform/` - reproducible source infrastructure
- `sql/` - schema, seed, incident, and validation SQL
- `scripts/` - supporting automation
- `docs/` - architecture, runbook, results, security, and cost decisions
- `evidence/` - sanitized portfolio evidence

## Security

- PostgreSQL credentials are not committed to Git.
- Terraform state is not committed.
- Saved Terraform plans are not committed.
- Raw evidence is excluded from Git.
- Public access is restricted to a single client IPv4.
- `require_secure_transport` was observed as `on`.
- Minimum TLS protocol was observed as `TLSv1.2`.

See `docs/security-cost.md`.

## Recovery runbook

See `docs/recovery-runbook.md`.

## Measured results

See `docs/results.md`.

## What this project does NOT prove

This project does not demonstrate:

- multi-region disaster recovery
- enterprise High Availability
- production-scale PostgreSQL
- automatic application failover
- guaranteed RTO
- guaranteed RPO
- Azure SLA compliance
- production-grade private networking

It demonstrates one tested Azure PostgreSQL logical-data-loss recovery workflow with measured recovery and programmatic validation.
