CREATE OR REPLACE TABLE data_quality.orders AS
SELECT
    COALESCE(error_reason, 'VALID') AS error_reason,
    COUNT(*) AS error_count,
    CURRENT_TIMESTAMP AS run_time
FROM transform.orders_validated
GROUP BY COALESCE(error_reason, 'VALID');
