# Evidence

This directory is for sanitized evidence suitable for a public portfolio.

Raw command output remains under `evidence/raw/` and is excluded from Git.

## Evidence checklist

Recommended evidence from the tested drill:

1. Azure Budget configuration.
2. Terraform plan summary.
3. Terraform apply success.
4. Source PostgreSQL Flexible Server configuration.
5. Source firewall configuration.
6. Initial 10-row dataset.
7. Baseline validation PASS.
8. PITR readiness summary.
9. Selected restore timestamp.
10. Controlled destructive incident.
11. Rows before deletion: 10.
12. Rows deleted: 10.
13. Rows after deletion: 0.
14. Post-incident validation FAIL.
15. Post-incident validation exit code 3.
16. PITR initiation.
17. Restored server Ready.
18. Restored firewall initially absent.
19. Restored firewall explicitly created.
20. Restored TCP 5432 connectivity successful.
21. Restored 10-row dataset.
22. Recovery validation PASS.
23. Recovery validation exit code 0.
24. Source row count 0 versus restored row count 10.
25. Recovery timing summary.
26. Terraform destroy success.
27. Final Azure cleanup verification.

## Sanitize before publishing

Remove or obscure:

- Subscription IDs
- Tenant IDs
- email addresses
- access tokens
- passwords
- public IPv4 addresses
- sensitive Terraform state
- unnecessary local filesystem information

Do not commit the contents of `evidence/raw/`.
