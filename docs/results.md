# Recovery Drill Results

## Outcome

The committed logical deletion was recovered through Azure Database for PostgreSQL Flexible Server Point-in-Time Restore.

PITR created a new server. The damaged source remained at 0 rows while the restored server returned the exact 10-row baseline and passed the same validator that failed against the source.

## Recorded timestamps

| Event | UTC timestamp |
|---|---|
| Selected restore point | `2026-09-18T22:52:02Z` |
| Incident | `2026-09-18T23:08:43.770121Z` |
| PITR initiation / recovery start | `2026-09-18T23:14:04.6896553Z` |
| Restored server first observed `Ready` | `2026-09-18T23:21:08.4979495Z` |
| Validation complete | `2026-09-18T23:28:09.6732747Z` |

## Observed measurements

| Measurement | Observed duration |
|---|---:|
| Selected recovery-point gap before incident | 16.70 minutes |
| PITR initiation to restored server `Ready` | 7.06 minutes |
| `Ready` to completed data validation | 7.02 minutes |
| Observed PITR initiation-to-validated-recovery duration | 14.08 minutes |
| Observed incident-to-validated-recovery elapsed time | approximately 19.43 minutes |

The 14.08-minute value begins when the PITR command was initiated and ends when the restored data passed validation. It is not labeled as RTO.

The 16.70-minute value describes the deliberately selected restore point relative to the incident. It is not labeled as RPO.

All values come from one controlled run. They are not Azure service guarantees and are not a statistical performance result.

## Data validation

| Check | Damaged source | Restored server |
|---|---:|---:|
| Row count | 0 | 10 |
| Total amount | Not applicable | 1230.75 |
| Minimum order ID | Not applicable | 1001 |
| Maximum order ID | Not applicable | 1010 |
| Exact expected row/value mismatches | 10 | 0 |
| Validator result | FAIL | PASS |
| Process exit code | 3 | 0 |

The restored server was not accepted based on Azure state alone. The tested completion criterion required:

1. the server to report `Ready`,
2. the single-client firewall rule to be recreated,
3. TCP port 5432 to be reachable,
4. PostgreSQL authentication to succeed, and
5. `sql/validation.sql` to return PASS with exit code 0.

## Cleanup verification

The restored server was deleted explicitly because it was not in the original Terraform state. The Terraform-managed resources were then destroyed.

Observed cleanup checks:

- restored-server lookup returned `ResourceNotFound`,
- destroy plan reported `0 to add, 0 to change, 5 to destroy`,
- final Terraform state list returned no entries,
- Resource Group existence check returned `false`, and
- no lab PostgreSQL Flexible Servers remained.

See the [sanitized evidence index](../evidence/README.md).
