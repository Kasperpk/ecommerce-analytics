CREATE OR REPLACE TABLE data_quality.order_lines AS
SELECT
    COALESCE(error_reason, 'VALID') AS error_reason,
    COUNT(*) AS error_count,
    CURRENT_TIMESTAMP AS run_time
FROM transform.order_lines_validated
GROUP BY COALESCE(error_reason, 'VALID');
