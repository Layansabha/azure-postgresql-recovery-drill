\set ON_ERROR_STOP on

\echo === CONTROLLED DATA LOSS INCIDENT ===

BEGIN;

SELECT
    clock_timestamp() AT TIME ZONE 'UTC'
        AS incident_timestamp_utc;

SELECT COUNT(*) AS rows_before_delete
FROM orders;

DELETE FROM orders;

SELECT COUNT(*) AS rows_after_delete
FROM orders;

COMMIT;

\echo === INCIDENT COMMITTED ===
