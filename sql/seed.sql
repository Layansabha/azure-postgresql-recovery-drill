\set ON_ERROR_STOP on

-- PRE-INCIDENT ONLY.
-- Do not rerun this script after the destructive test.

INSERT INTO orders (order_id, customer_ref, amount, status, created_at)
VALUES
    (1001, 'customer-001', 125.50, 'paid',       '2026-09-18 18:00:00+00'),
    (1002, 'customer-002',  89.99, 'processing', '2026-09-18 18:05:00+00'),
    (1003, 'customer-003', 240.00, 'shipped',    '2026-09-18 18:10:00+00'),
    (1004, 'customer-004',  59.25, 'paid',       '2026-09-18 18:15:00+00'),
    (1005, 'customer-005', 310.40, 'processing', '2026-09-18 18:20:00+00'),
    (1006, 'customer-006',  45.00, 'shipped',    '2026-09-18 18:25:00+00'),
    (1007, 'customer-007',  78.80, 'paid',       '2026-09-18 18:30:00+00'),
    (1008, 'customer-008', 199.99, 'processing', '2026-09-18 18:35:00+00'),
    (1009, 'customer-009',  15.75, 'shipped',    '2026-09-18 18:40:00+00'),
    (1010, 'customer-010',  66.07, 'paid',       '2026-09-18 18:45:00+00')
ON CONFLICT (order_id) DO NOTHING;
