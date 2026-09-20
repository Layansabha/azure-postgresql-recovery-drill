# Terraform

This directory defines the source infrastructure used by the completed recovery drill:

- Resource Group
- PostgreSQL Flexible Server
- `recoverylab` database
- single-client IPv4 firewall rule
- random suffix for the globally unique server name

The September 2026 run used Terraform 1.16.3, AzureRM 5.6.0, and random 3.9.x. The initial plan reported `5 to add, 0 to change, 0 to destroy`.

## Inputs

Defaults are defined for the region, resource names, database, and administrator username. Supply secrets and workstation-specific values through the environment rather than a committed tfvars file:

```powershell
$env:TF_VAR_admin_password = "<strong-password>"
$env:TF_VAR_client_ip = "<current-public-ipv4>"
```

Review `terraform plan` before any apply. Azure resources are billable, and this repository's published evidence does not require the lab to be provisioned again.

The PITR-restored server is created operationally by Azure CLI and is not managed by this Terraform state. Delete it explicitly before destroying the source infrastructure.
