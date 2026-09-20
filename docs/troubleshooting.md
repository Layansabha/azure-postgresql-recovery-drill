# Troubleshooting Notes

These issues occurred during the completed lab. They are retained because they changed the final workflow.

## Write-only administrator password

The Terraform resource used `administrator_password_wo`. After provisioning, the original locally available password was no longer available for psql authentication.

The fix was to reset the PostgreSQL administrator password through Azure and store the replacement locally with Windows DPAPI in `.local/pg-admin-password.dpapi`. The directory was already ignored by Git.

Lesson: a write-only Terraform argument reduces password retention in Terraform, but the operator still needs a deliberate secret lifecycle for later database access. A repeat run should prepare that lifecycle before `apply`.

## Validator returned the wrong process status

An early validator tried to use `\quit 3`. With the installed psql version, the numeric argument was ignored and the process returned 0 even though the output said FAIL.

The final validator raises a PostgreSQL exception and runs with psql `ON_ERROR_STOP`. The tested damaged state returned exit code 3, and the recovered state returned 0.

Lesson: automation must evaluate a reliable process exit code, not search console text for PASS or FAIL.

## `Ready` timestamp was overwritten

The local file holding the restored server's availability time was later overwritten by another status check.

The measurement was corrected to the first recorded observation of `Ready`: `2026-09-18T23:21:08.4979495Z`.

Lesson: timestamp files should be append-only or written once after an explicit existence check.

## Azure CLI parameter mismatches

Two commands initially used incorrect parameter assumptions:

- firewall-rule listing required `--server-name`,
- database show used `--name` for the database name.

The fix was to check the installed Azure CLI command help instead of inferring option names.

## TLS table output

`az postgres flexible-server parameter show --output table` did not return a usable table for the TLS parameter checks.

The working approach used JSON output with `ConvertFrom-Json`, then printed only `require_secure_transport` and `ssl_min_protocol_version`.

## SQL entered in PowerShell

Typing `DELETE FROM orders;` directly into PowerShell produced a command-not-found error and did not modify PostgreSQL.

The incident was executed through psql using the checked-in SQL file. This also made the destructive statement reviewable before execution.
