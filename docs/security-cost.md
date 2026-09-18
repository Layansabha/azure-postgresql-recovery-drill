# Security and Cost Decisions

## Security approach

The project uses security controls appropriate for a short-lived learning lab while documenting where production architecture would differ.

## Network access

The PostgreSQL Flexible Servers use public network access.

This was selected because the PostgreSQL client runs directly from a local Windows workstation and the goal of the project is recovery testing rather than private-network architecture.

Access was restricted using a server-level firewall rule with:

- one current client public IPv4,
- identical start and end IP addresses,
- no broad client range,
- no unrestricted Azure-wide firewall rule.

The restored PITR server required its own firewall rule because the source firewall rule was not inherited.

For sensitive production systems, private networking would normally be preferred.

## TLS

Observed on both source and restored servers:

- `require_secure_transport = on`
- `ssl_min_protocol_version = TLSv1.2`

The PostgreSQL client connection used:

`sslmode=require`

The project therefore verifies encrypted transport.

It does not claim to be a PKI-hardening or certificate-lifecycle implementation.

## PostgreSQL credentials

The administrator password is not stored in Git.

During the lab it was stored locally using Windows DPAPI under:

`.local/pg-admin-password.dpapi`

The `.local/` directory is excluded from Git.

The password itself is not printed in project documentation or evidence.

## Terraform state

Terraform state is treated as sensitive operational data.

The repository excludes:

- `*.tfstate`
- `*.tfstate.*`
- `tfplan`
- `.terraform/`
- `.local/`
- `evidence/raw/`
- `.env`

The committed `.terraform.lock.hcl` is intentionally retained because it records Terraform provider selections and checksums.

## Evidence handling

Raw command output may contain:

- Subscription IDs
- Tenant IDs
- email addresses
- public IPv4 addresses
- Azure resource identifiers
- local filesystem information

Raw evidence remains under `evidence/raw/` and is excluded from Git.

Only sanitized evidence should be published.

## Cost controls

Before deployment:

- Azure Free Account credit was confirmed.
- USD 200 promotional credit was visible.
- A USD 5 monthly Azure Budget was created.
- Budget alerts were treated as notifications, not as a hard spending cap.

The lab was intentionally kept small.

Source server configuration:

- Standard_B1ms
- 32 GiB storage
- 7-day backup retention
- High Availability disabled
- Geo-redundant backup disabled
- Storage autogrow disabled

The lab does not use:

- Azure VM
- AKS
- NAT Gateway
- multi-region deployment
- additional observability stack
- enterprise HA

## Observed pricing information

During planning, the Azure Retail Prices API returned approximately:

- UAE North B1ms compute: USD 0.020 per hour
- UAE North backup-storage overage meter: USD 0.105 per GB-month

An exact UAE North primary-storage retail meter was not successfully retrieved during the experiment, so this project does not claim an exact final storage rate.

Actual final cost must be reviewed in Azure Cost Management because billing data can be delayed.

## PITR cost risk

Point-in-Time Restore creates another PostgreSQL Flexible Server.

For part of the recovery drill, both the damaged source server and restored server exist simultaneously.

This increases temporary resource consumption.

Therefore the restored server must be explicitly deleted immediately after recovery evidence is complete.

## Cost cleanup

The cleanup procedure is:

1. Delete the PITR-restored server.
2. Verify the restored server no longer exists.
3. Run `terraform destroy`.
4. Verify the source Flexible Server is gone.
5. Verify the Resource Group no longer contains unnecessary resources.
6. Review Azure Cost Management after cleanup.

## Cost claim limitation

The project does not claim that Azure PostgreSQL is universally free.

Any free allowance or promotional credit depends on the actual subscription and applicable Azure offer.

The configuration was selected to minimize lab cost, not to prove a permanent zero-cost architecture.
