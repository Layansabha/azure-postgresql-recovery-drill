# Recovery Drill Results

## Outcome

The controlled PostgreSQL logical data-loss incident was successfully recovered using Azure Database for PostgreSQL Flexible Server Point-in-Time Restore.

The original source server remained in the failed state with 0 rows in the `orders` table.

The restored server returned the expected 10-row baseline and passed the same deterministic validation script that failed against the damaged source.

## Measured timestamps

| Event | UTC timestamp |
|---|---|
| Selected restore point | 2026-09-18T22:52:02Z |
| Incident | 2026-09-18T23:08:43.770121Z |
| Recovery started | 2026-09-18T23:14:04.6896553Z |
| Restored server first observed Ready | 2026-09-18T23:21:08.4979495Z |
| Validation completed | 2026-09-18T23:28:09.6732747Z |

## Observed results

- Selected recovery-point gap: 16.70 minutes
- Observed time from PITR initiation to restored server Ready: 7.06 minutes
- Post-Ready networking/connectivity/validation work: 7.02 minutes
- Observed end-to-end recovery duration: 14.08 minutes

## Validation

Damaged source server:

- `orders` row count: 0
- validation result: FAIL
- validation process exit code: 3

Restored server:

- `orders` row count: 10
- total amount: 1230.75
- minimum order ID: 1001
- maximum order ID: 1010
- validation result: PASS
- validation process exit code: 0

## Interpretation

The observed recovery duration is a measurement from one controlled lab run, not a guaranteed RTO or Azure SLA.

The selected recovery point was 16.70 minutes before the incident. This is a deliberately chosen recovery-point gap for the experiment and is not a guaranteed RPO.

The test does not demonstrate multi-region disaster recovery, production scale, enterprise high availability, or guaranteed recovery objectives.

## Cleanup verification

After recovery evidence was collected, the temporary Azure resources were removed.

Verified cleanup results:

- PITR-restored PostgreSQL Flexible Server deleted.
- Restored server lookup returned `ResourceNotFound`.
- Terraform destroy plan showed:
  - 0 to add
  - 0 to change
  - 5 to destroy
- Terraform state after cleanup was empty.
- Resource Group existence check returned `false`.
- Azure PostgreSQL Flexible Server list returned no remaining servers in the subscription.

The lab therefore did not leave the source or restored PostgreSQL servers running after completion.

## Final project status

The tested recovery drill completed the full intended workflow:

Known data
-> controlled destructive event
-> verified data loss
-> Azure Point-in-Time Restore
-> restored-server network recovery
-> programmatic recovery validation
-> measured recovery
-> Azure resource cleanup

Observed end-to-end recovery duration for this lab run: 14.08 minutes.

This remains an observed lab measurement, not a guaranteed RTO or RPO.
