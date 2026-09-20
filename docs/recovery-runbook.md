# PostgreSQL Recovery Runbook

This is the sequence tested during the completed lab. It contains a destructive step and should only be used with a disposable environment and an approved cleanup plan.

## 1. Before the incident

1. Confirm the source Flexible Server reports `Ready`.
2. Confirm 7-day backup retention and an available restore window.
3. Run the baseline validator:

   ```powershell
   & psql $sourceConn -X -w -v ON_ERROR_STOP=1 -f "$repo\sql\validation.sql"
   if ($LASTEXITCODE -ne 0) { throw "Baseline validation failed" }
   ```

4. Record the expected baseline: 10 rows, total 1230.75, IDs 1001-1010.
5. Select a known-safe UTC restore point later than Azure's earliest restore point.
6. Persist that restore point before the destructive action.

The completed run selected `2026-09-18T22:52:02Z`.

## 2. Controlled incident

Run [`sql/incident.sql`](../sql/incident.sql) only after the previous checks:

```powershell
psql $sourceConn -X -w -v ON_ERROR_STOP=1 -f "$repo\sql\incident.sql"
```

Require evidence that the transaction committed, 10 rows were deleted, and the source row count is 0. Run the validator again and require a non-zero exit status. The completed run returned exit code 3.

Do not reseed or modify the damaged source after the incident.

## 3. Start PITR

Record the recovery start immediately before initiating PITR:

```powershell
$recoveryStart = [DateTime]::UtcNow.ToString("o")
$recoveryStart | Set-Content "$repo\evidence\raw\T_recovery_start.txt"

az postgres flexible-server restore `
  --resource-group $rgName `
  --name $restoredName `
  --source-server $serverName `
  --restore-time $restoreTime `
  --yes
```

PITR creates a new Flexible Server. It does not overwrite the source.

Poll the restored server until it first reports `Ready`, then record that first observation. Do not replace it with a later status-check time.

## 4. Rebuild network access

List restored-server firewall rules. The completed run showed that the source rule was not inherited.

Create one rule for the current client IPv4, then verify the rule exists:

```powershell
$currentIp = (Invoke-RestMethod -Uri "https://api4.ipify.org").Trim()

az postgres flexible-server firewall-rule create `
  --resource-group $rgName `
  --server-name $restoredName `
  --name allow-current-client `
  --start-ip-address $currentIp `
  --end-ip-address $currentIp
```

Test TCP connectivity before attempting data validation:

```powershell
Test-NetConnection -ComputerName $restoredFqdn -Port 5432
```

## 5. Authenticate and validate

Build the restored connection with `sslmode=require`, verify PostgreSQL authentication, and run the same validator:

```powershell
$restoredConn = "host=$restoredFqdn port=5432 dbname=$dbName user=$adminUser sslmode=require"

psql $restoredConn -X -w -v ON_ERROR_STOP=1 `
  -c "SELECT current_database(), current_user, version();"

& psql $restoredConn -X -w -v ON_ERROR_STOP=1 -f "$repo\sql\validation.sql"
if ($LASTEXITCODE -ne 0) { throw "Recovered data validation failed" }
```

Record validation completion only after exit code 0. Then compare both servers:

- damaged source: 0 rows,
- restored server: 10 rows.

Azure `Ready` status alone is not the recovery completion criterion.

## 6. Measure

Calculate and retain these separate intervals:

- selected restore point to incident,
- PITR initiation to first `Ready` observation,
- first `Ready` observation to completed validation,
- PITR initiation to validated recovery, and
- incident to validated recovery.

Do not relabel one observed run as a guaranteed RTO or RPO.

## 7. Cleanup

The restored server is outside the original Terraform state. Cleanup order matters:

1. Preserve sanitized recovery evidence.
2. Delete the restored server explicitly.
3. Confirm a lookup returns `ResourceNotFound`.
4. Review `terraform plan -destroy`.
5. Run `terraform destroy` for the five managed objects.
6. Confirm `terraform state list` is empty.
7. Confirm the Resource Group does not exist.
8. Confirm no lab Flexible Servers remain.
9. Review Azure Cost Management after billing data settles.

The completed run finished all checks above. Do not run `apply`, PITR, or `destroy` merely to re-create the published evidence.
