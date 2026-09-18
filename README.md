# Azure PostgreSQL Recovery Drill

Controlled data loss ? Point-in-Time Restore ? programmatic validation ? measured recovery.

## Engineering problem

A backup existing is not proof that recovery works.

This project tests a controlled PostgreSQL logical data-loss incident on Azure Database for PostgreSQL Flexible Server, restores the database to a safe point before the incident, validates the recovered data programmatically, and records observed recovery timings.

## Status

Build in progress.

## What this project does NOT prove

- Not multi-region disaster recovery
- Not enterprise high availability
- Not production-scale PostgreSQL
- Not a guaranteed RTO or RPO
- Not an Azure SLA validation exercise
