\set ON_ERROR_STOP on

SELECT
    COUNT(*) AS row_count,
    COALESCE(SUM(amount), 0) AS total_amount,
    MIN(order_id) AS min_order_id,
    MAX(order_id) AS max_order_id
FROM orders;

DO $$
DECLARE
    actual_count   integer;
    mismatch_count integer;
BEGIN
    SELECT COUNT(*)
    INTO actual_count
    FROM orders;

    SELECT COUNT(*)
    INTO mismatch_count
    FROM (
        WITH expected(order_id, customer_ref, amount, status, created_at) AS (
            VALUES
                (1001, 'customer-001', 125.50::numeric(10,2), 'paid',       TIMESTAMPTZ '2026-09-18 18:00:00+00'),
                (1002, 'customer-002',  89.99::numeric(10,2), 'processing', TIMESTAMPTZ '2026-09-18 18:05:00+00'),
                (1003, 'customer-003', 240.00::numeric(10,2), 'shipped',    TIMESTAMPTZ '2026-09-18 18:10:00+00'),
                (1004, 'customer-004',  59.25::numeric(10,2), 'paid',       TIMESTAMPTZ '2026-09-18 18:15:00+00'),
                (1005, 'customer-005', 310.40::numeric(10,2), 'processing', TIMESTAMPTZ '2026-09-18 18:20:00+00'),
                (1006, 'customer-006',  45.00::numeric(10,2), 'shipped',    TIMESTAMPTZ '2026-09-18 18:25:00+00'),
                (1007, 'customer-007',  78.80::numeric(10,2), 'paid',       TIMESTAMPTZ '2026-09-18 18:30:00+00'),
                (1008, 'customer-008', 199.99::numeric(10,2), 'processing', TIMESTAMPTZ '2026-09-18 18:35:00+00'),
                (1009, 'customer-009',  15.75::numeric(10,2), 'shipped',    TIMESTAMPTZ '2026-09-18 18:40:00+00'),
                (1010, 'customer-010',  66.07::numeric(10,2), 'paid',       TIMESTAMPTZ '2026-09-18 18:45:00+00')
        )
        (
            SELECT order_id, customer_ref, amount, status, created_at
            FROM expected

            EXCEPT

            SELECT order_id, customer_ref::text, amount, status::text, created_at
            FROM orders
        )

        UNION ALL

        (
            SELECT order_id, customer_ref::text, amount, status::text, created_at
            FROM orders

            EXCEPT

            SELECT order_id, customer_ref, amount, status, created_at
            FROM expected
        )
    ) AS differences;

    IF actual_count <> 10 OR mismatch_count <> 0 THEN
        RAISE EXCEPTION
            'VALIDATION FAIL: expected exact 10-row baseline; actual_count=%, mismatches=%',
            actual_count,
            mismatch_count;
    END IF;
END
$$;

\echo VALIDATION PASS: orders table exactly matches the expected 10-row baseline.
