# Sanitized Evidence Index

These files record the major milestones from the completed September 2026 recovery drill.

The records were transcribed from the sanitized Study Guide after the lab. They preserve observed commands, values, and results, but they are not presented as untouched terminal log files. Raw captures remain excluded under `evidence/raw/` because they can contain subscription IDs, public IP addresses, resource IDs, email addresses, and local paths.

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

No screenshots were manufactured for publication. Text evidence is used where no sanitized screenshot was captured.
