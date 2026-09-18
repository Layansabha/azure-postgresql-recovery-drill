\set ON_ERROR_STOP on

BEGIN;

CREATE TABLE IF NOT EXISTS orders (
    order_id      INTEGER PRIMARY KEY,
    customer_ref  VARCHAR(32) NOT NULL,
    amount        NUMERIC(10,2) NOT NULL CHECK (amount > 0),
    status        VARCHAR(20) NOT NULL CHECK (status IN ('paid', 'processing', 'shipped')),
    created_at    TIMESTAMPTZ NOT NULL
);

COMMIT;
