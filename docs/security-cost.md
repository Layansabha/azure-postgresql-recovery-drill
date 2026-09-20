# Security and Cost Decisions

## Public network access

The lab used public access so PostgreSQL could be operated directly from a Windows workstation. This kept the experiment focused on recovery and avoided adding a VNet, VM, NAT Gateway, or private endpoint.

The tradeoff was controlled by using:

- one current-client IPv4 firewall rule on the source server,
- one current-client IPv4 firewall rule recreated on the restored server,
- identical start and end IP addresses, and
- no broad `0.0.0.0` access rule.

Private networking would be more appropriate for many production environments. It was outside this lab's scope.

## TLS

Both source and restored servers were observed with:

- `require_secure_transport = on`
- `ssl_min_protocol_version = TLSv1.2`

The psql connection string used `sslmode=require`. This required an encrypted connection, but it did not provide the strongest hostname and server-certificate verification. The lab did not implement or claim `verify-full`.

## Administrator credential handling

The Terraform configuration used `administrator_password_wo`, a write-only password argument. That avoided retaining the administrator password as a normal Terraform value, but it did not solve the local credential lifecycle.

During the completed run, the original locally available password was no longer available after provisioning. The administrator password was reset through Azure, then the replacement was stored locally with Windows DPAPI at:

`.local/pg-admin-password.dpapi`

The `.local/` directory was ignored by Git. No credential value is present in the repository or public evidence.

For a repeat run, the credential should be generated or captured once in an approved secret manager or protected local workflow before `terraform apply`, then made available to both Terraform and the PostgreSQL client without printing it. This lesson is operational, not an architectural feature of the lab.

## Terraform and local artifacts

The repository excludes:

- `*.tfstate` and `*.tfstate.*`
- `.terraform/`
- `*.tfplan` and `tfplan`
- `.env` and `.env.*`
- `.local/`
- `evidence/raw/`

The provider lock file is committed because it records provider versions and checksums; it does not contain the administrator password.

## Evidence handling

Raw output stayed in the ignored `evidence/raw/` directory because it could contain subscription IDs, tenant IDs, email addresses, public IP addresses, Azure resource IDs, and local paths.

Published evidence is sanitized and labeled as either a transcript excerpt or a summary. The repository does not claim that a reformatted summary is verbatim terminal output.

## Cost choices

The source used a small lab configuration:

- `Standard_B1ms`
- 32 GiB storage
- 7-day backup retention
- High Availability disabled
- geo-redundant backup disabled
- storage autogrow disabled

A USD 5 Azure Budget was configured as a notification guardrail. It was not treated as a spending cap.

PITR temporarily created a second billable server. Cleanup therefore removed the restored server first, then destroyed the Terraform-managed source infrastructure and verified that no lab servers remained.

The project does not claim an exact final cost or a permanently free architecture.

## References

- [Microsoft Learn: Backup and restore in Azure Database for PostgreSQL Flexible Server](https://learn.microsoft.com/en-us/azure/postgresql/backup-restore/concepts-backup-restore)
- [Microsoft Learn: TLS in Azure Database for PostgreSQL Flexible Server](https://learn.microsoft.com/en-us/azure/postgresql/security/security-tls)
- [PostgreSQL: SSL support and sslmode behavior](https://www.postgresql.org/docs/current/libpq-ssl.html)
