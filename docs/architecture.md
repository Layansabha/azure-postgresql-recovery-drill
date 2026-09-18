# Architecture

## Goal

Demonstrate a real Azure PostgreSQL recovery drill:

Known data
? controlled logical data loss
? Point-in-Time Restore
? restored networking
? programmatic validation
? measured recovery
? cleanup.

## Architecture Overview

Windows 11 Workstation
|
|-- Terraform
|-- Azure CLI
|-- psql
|-- PowerShell
|
+--> Azure Resource Group: rg-pg-recovery-lab
     |
     +--> Source PostgreSQL Flexible Server
     |    |
     |    |-- PostgreSQL 17
     |    |-- Standard_B1ms
     |    |-- 32 GiB storage
     |    |-- 7-day backup retention
     |    |-- High Availability disabled
     |    |-- Geo-redundant backup disabled
     |    |-- Public network access enabled
     |    |
     |    +--> Firewall rule
     |    |    Current client public IPv4 only
     |    |
     |    +--> Database: recoverylab
     |         |
     |         +--> orders table
     |              |
     |              +--> Known 10-row baseline
     |              |
     |              +--> Controlled DELETE
     |                   |
     |                   +--> Source state: 0 rows
     |
     +--> Azure Point-in-Time Restore
          |
          +--> New Restored PostgreSQL Flexible Server
               |
               |-- Same PostgreSQL major version
               |-- Same B1ms compute class
               |-- Same 32 GiB storage size
               |-- Public networking enabled
               |
               +--> Source firewall rule is NOT inherited
                    |
                    +--> Create new restored-server firewall rule
                         |
                         +--> Verify TCP port 5432
                              |
                              +--> Connect using psql
                                   |
                                   +--> Run deterministic validation
                                        |
                                        +--> PASS: 10-row baseline recovered

## Implemented Configuration

The source environment was provisioned with Terraform.

Configuration:

- Azure region: UAE North
- Azure service: Azure Database for PostgreSQL Flexible Server
- PostgreSQL major version: 17
- Compute SKU: Standard_B1ms
- Storage: 32 GiB
- Backup retention: 7 days
- High Availability: disabled
- Geo-redundant backup: disabled
- Storage autogrow: disabled
- Public network access: enabled
- Firewall access: restricted to one current client public IPv4
- Password authentication: enabled
- TLS transport: required
- Minimum TLS protocol observed: TLSv1.2

## Data-Loss Scenario

The experiment uses a simple `orders` table containing a deterministic 10-row dataset.

Before the incident, validation confirmed:

- Row count: 10
- Total amount: 1230.75
- Minimum order ID: 1001
- Maximum order ID: 1010
- Exact dataset comparison: PASS

The controlled incident performs a logical deletion of all rows from the `orders` table.

After the incident:

- Source row count: 0
- Deterministic validation: FAIL
- Validation process exit code: 3

The PostgreSQL server, database, and table remain available. Only the application data is deliberately removed.

## Point-in-Time Restore Design

A restore timestamp was selected before the destructive event.

Selected restore point:

2026-09-18T22:52:02Z

Incident timestamp:

2026-09-18T23:08:43.770121Z

Azure Point-in-Time Restore creates a new PostgreSQL Flexible Server rather than overwriting the damaged source server.

This lets the experiment compare:

- damaged source server
- recovered restored server

at the same time.

## Restored-Server Networking

The restored server uses public networking, but the source server firewall rule is not inherited during Point-in-Time Restore.

The recovery procedure therefore explicitly performs:

1. Wait for the restored server to become Ready.
2. Confirm no source firewall rule was copied.
3. Determine the current client public IPv4.
4. Create a new firewall rule on the restored server.
5. Verify the rule exists.
6. Verify TCP connectivity to port 5432.
7. Authenticate using `psql`.
8. Run programmatic recovery validation.

This networking restoration step is treated as part of the recovery procedure rather than an optional configuration task.

## Recovery Validation

The same deterministic validation script is used before and after the incident.

Damaged source:

- Row count: 0
- Validation result: FAIL
- Exit code: 3

Restored server:

- Row count: 10
- Total amount: 1230.75
- Minimum order ID: 1001
- Maximum order ID: 1010
- Exact dataset comparison: PASS
- Exit code: 0

The experiment therefore does not treat Azure reporting the restore as complete as sufficient evidence.

Recovery is considered successful only after the restored PostgreSQL data passes programmatic validation.

## Measured Recovery

Observed timestamps from the tested run:

- Selected restore point:
  2026-09-18T22:52:02Z

- Incident:
  2026-09-18T23:08:43.770121Z

- Recovery started:
  2026-09-18T23:14:04.6896553Z

- Restored server first observed Ready:
  2026-09-18T23:21:08.4979495Z

- Recovery validation completed:
  2026-09-18T23:28:09.6732747Z

Observed measurements:

- Selected recovery-point gap: 16.70 minutes
- PITR initiation to restored server Ready: 7.06 minutes
- Restored server Ready to validated recovery: 7.02 minutes
- End-to-end observed recovery duration: 14.08 minutes

These are measurements from one controlled lab run.

They are not guaranteed RTO or RPO values and are not Azure SLA claims.

## Infrastructure Ownership

Terraform manages the original source infrastructure:

- Resource Group
- Source PostgreSQL Flexible Server
- Source database
- Source firewall rule

The PITR-restored server is created operationally during the recovery procedure.

It is not part of the original Terraform state.

Because of that, cleanup must happen in this order:

1. Delete the restored PostgreSQL server explicitly.
2. Verify the restored server and its firewall configuration are gone.
3. Run `terraform destroy`.
4. Verify the Terraform-managed source resources are removed.
5. Verify no unnecessary Azure resources remain.

## Security Design

Security controls used in the lab:

- Public PostgreSQL access restricted to one client public IPv4.
- No broad `0.0.0.0` firewall rule.
- TLS transport required.
- Minimum observed TLS version: TLSv1.2.
- PostgreSQL password not committed to Git.
- Terraform state not committed to Git.
- Terraform plan files not committed to Git.
- Raw evidence containing sensitive identifiers excluded from Git.

Public networking was selected as a deliberate lab simplification.

Private networking would generally be preferred for sensitive production environments.

## Cost Design

The lab intentionally uses a small configuration:

- Standard_B1ms
- 32 GiB storage
- no High Availability
- no geo-redundant backup
- no VM
- no Kubernetes
- no NAT Gateway
- no unnecessary monitoring stack

During PITR, both the damaged source server and the restored server exist at the same time.

The restored server must therefore be deleted after evidence collection to avoid unnecessary continued consumption.

## What This Architecture Does Not Prove

This architecture does not demonstrate:

- multi-region disaster recovery
- enterprise High Availability
- production-scale PostgreSQL
- automatic application failover
- guaranteed RTO
- guaranteed RPO
- Azure SLA compliance
- production-grade private networking

It demonstrates one tested Azure PostgreSQL logical-data-loss recovery workflow with measured recovery and programmatic validation.
