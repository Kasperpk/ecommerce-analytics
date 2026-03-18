CREATE OR REPLACE TABLE transform.orders_validated AS
SELECT * FROM (
    WITH validated AS (
        SELECT *,
            CASE
                WHEN TRY_CAST(SUBSTRING(order_id, 2, 1) AS INT) IS NULL
                THEN 'INVALID_ORDER_ID'
            END AS rule_order_id,

            CASE
                WHEN TRY_CAST(order_ts AS DATETIME) IS NULL
                THEN 'INVALID_TIMESTAMP'
            END AS rule_order_ts
        FROM bronze.orders
    )
    SELECT *,
        NULLIF(CONCAT_WS('|', rule_order_id, rule_order_ts), '') AS error_reason
    FROM validated
) t;
