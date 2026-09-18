# PostgreSQL Recovery Runbook

## Purpose

Recover a known PostgreSQL dataset after a controlled logical data-loss event using Azure Database for PostgreSQL Flexible Server Point-in-Time Restore.

This runbook records the procedure that was actually tested in the lab.

## Preconditions

Before any destructive operation:

- Source PostgreSQL Flexible Server is in `Ready` state.
- Backup retention is 7 days.
- Azure reports an available full backup.
- The selected restore timestamp is later than the earliest available restore point.
- The expected dataset has been recorded.
- Baseline validation returns PASS.
- Recovery evidence has been captured.
- The intended restore timestamp has been fixed before the incident.

## Expected baseline

Database:

`recoverylab`

Table:

`orders`

Expected state:

- Row count: 10
- Total amount: 1230.75
- Minimum order ID: 1001
- Maximum order ID: 1010
- Exact expected dataset comparison: PASS

## Tested restore point

Selected restore timestamp:

`2026-09-18T22:52:02Z`

Incident timestamp:

`2026-09-18T23:08:43.770121Z`

The restore timestamp was intentionally selected before the destructive event.

## Controlled incident

The destructive operation is:

    DELETE FROM orders;

The tested incident produced:

- rows before deletion: 10
- rows deleted: 10
- rows after deletion: 0
- transaction committed

After the incident:

- source row count: 0
- validation result: FAIL
- validation process exit code: 3

## Recovery procedure

1. Confirm the source data-loss state.
2. Confirm the previously selected restore timestamp.
3. Record `T_recovery_start`.
4. Start Azure PostgreSQL Flexible Server Point-in-Time Restore.
5. Restore to the selected UTC timestamp.
6. Wait until the new restored server reports `Ready`.
7. Record `T_restore_available`.
8. Confirm that the restored server is a separate server from the damaged source.
9. List the restored server firewall rules.
10. Confirm that the source firewall rule was not inherited.
11. Determine the current client public IPv4.
12. Create a new firewall rule on the restored server for that IPv4 only.
13. Verify the restored firewall rule exists.
14. Verify TCP connectivity to port 5432.
15. Authenticate to the restored server using `psql`.
16. Confirm the expected database exists.
17. Confirm the `orders` table exists.
18. Run `sql/validation.sql`.
19. Require validation result PASS and process exit code 0.
20. Record `T_validation_complete`.
21. Query the damaged source server.
22. Confirm the source still contains 0 rows.
23. Query the restored server.
24. Confirm the restored server contains 10 rows.
25. Calculate observed recovery measurements.
26. Preserve sanitized evidence.
27. Delete the restored server explicitly.
28. Verify the restored server is gone.
29. Run `terraform destroy` for the Terraform-managed source infrastructure.
30. Verify no unnecessary Azure resources remain.

## Restored-server firewall requirement

The PITR-restored server did not inherit the source Flexible Server firewall rule.

Therefore the tested network recovery sequence was:

Restored server Ready
-> inspect firewall rules
-> create current-client firewall rule
-> verify firewall rule
-> verify TCP 5432
-> authenticate with PostgreSQL
-> validate recovered data

Database validation must not start before restored-server connectivity is confirmed.

## Validation criteria

Recovery is considered successful only if all of the following are true:

- PostgreSQL authentication succeeds.
- Database `recoverylab` exists.
- Table `orders` exists.
- Row count is exactly 10.
- Total amount is exactly 1230.75.
- Minimum order ID is 1001.
- Maximum order ID is 1010.
- Exact expected dataset comparison succeeds.
- Validation process exit code is 0.

Azure reporting the restore operation as complete is not sufficient recovery evidence.

## Failure handling

If restore, networking, authentication, or validation fails:

- do not modify or reseed the damaged source,
- preserve the exact error output,
- inspect the actual Azure resource state,
- diagnose the failing layer,
- retry only after the cause is understood.

## Cleanup order

The restored server is created operationally by PITR and is not part of the original Terraform state.

Cleanup order:

1. Preserve final recovery evidence.
2. Delete the restored PostgreSQL Flexible Server.
3. Verify the restored server is no longer present.
4. Verify its associated firewall configuration is gone.
5. Run `terraform destroy`.
6. Verify Terraform reports successful destruction.
7. Verify the Resource Group and billable resources are removed.
8. Review Azure Cost Management.

## Important limitation

This runbook documents one controlled lab recovery.

It is not a production disaster-recovery procedure and does not define guaranteed RTO or RPO values.
