CREATE OR REPLACE TABLE transform.refunds_validated AS
SELECT * FROM (
    WITH validated AS (
        SELECT *,
            CASE
                WHEN TRY_CAST(SUBSTRING(refund_id, 2, 1) AS INT) IS NULL
                THEN 'INVALID_REFUND_ID'
            END AS rule_refund_id,

            CASE
                WHEN TRY_CAST(refund_ts AS DATETIME) IS NULL
                THEN 'INVALID_TIMESTAMP'
            END AS rule_refund_ts
        FROM bronze.refunds
    )
    SELECT *,
        NULLIF(CONCAT_WS('|', rule_refund_id, rule_refund_ts), '') AS error_reason
    FROM validated
) t;
