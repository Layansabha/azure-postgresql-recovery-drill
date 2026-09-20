# Sanitized Evidence Index

These files record the major milestones from the completed September 2026 recovery drill.

The records were transcribed from the sanitized Study Guide after the lab. They preserve observed commands, values, and results, but they are not presented as untouched terminal log files. Raw captures remain excluded under `evidence/raw/` because they can contain subscription IDs, public IP addresses, resource IDs, email addresses, and local paths.

## Screenshot evidence

| Screenshot | What it shows |
|---|---|
| [Controlled DELETE](screenshots/01-controlled-delete.jpeg) | Incident timestamp, 10 rows before deletion, `DELETE 10`, 0 rows after, and `COMMIT` |
| [Post-incident validation failure](screenshots/02-post-incident-validation-fail.jpeg) | Source aggregates at zero and the deterministic validator exception |
| [Restored server Ready](screenshots/03-pitr-restored-server-ready.jpeg) | New PITR server in `Ready` state with the tested region, version, SKU, storage, and public access |
| [Firewall before repair](screenshots/04-restored-firewall-before-fix.jpeg) | Restored-server firewall listing before a rule was added; the command returned no rows |
| [Firewall after repair](screenshots/05-restored-firewall-after-fix.jpeg) | Recreated `allow-current-client` rule; both IP values are redacted |
| [Recovery validation PASS](screenshots/06-recovery-validation-pass.jpeg) | Restored aggregates and exact 10-row validation PASS |
| [Cleanup verification](screenshots/07-cleanup-verification.jpeg) | Empty Terraform state, absent Resource Group, and no server rows returned |

The screenshots are exact crops of the original terminal captures. Solid black redactions cover the client public IP and local Windows user path only. No command output was regenerated or rewritten.

## Text evidence

| Evidence | What it supports |
|---|---|
| [01 - Terraform plan](01-terraform-plan.txt) | Tool/provider versions and initial `5 to add` plan |
| [02 - Baseline validation](02-baseline-validation.txt) | Deterministic 10-row baseline and validator PASS |
| [03 - Controlled incident](03-controlled-incident.txt) | Committed deletion, 0-row source, validator FAIL / exit 3 |
| [04 - PITR and network recovery](04-pitr-network-recovery.txt) | New server, first `Ready` observation, firewall rebuild, TCP test |
| [05 - Recovered data validation](05-recovery-validation.txt) | Restored validator PASS / exit 0 and source-versus-restored proof |
| [06 - Recovery measurements](06-recovery-measurements.txt) | Recorded UTC timestamps and calculated durations |
| [10a - Terraform destroy plan](10a-terraform-destroy-plan.txt) | Sanitized destroy-plan summary: `5 to destroy` |
| [10b - Cleanup verification](10b-cleanup-verification.txt) | Empty state, absent Resource Group, no lab servers |

No screenshots were manufactured for publication. Text evidence remains available for milestones that were not captured cleanly as images.
