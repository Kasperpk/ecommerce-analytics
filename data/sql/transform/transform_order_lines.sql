CREATE OR REPLACE TABLE transform.order_lines_validated AS
SELECT * FROM (
    WITH validated AS (
        SELECT *,
            CASE
                WHEN TRY_CAST(SUBSTRING(order_line_id, 2, 1) AS INT) IS NULL
                THEN 'INVALID_ORDER_LINE_ID'
            END AS rule_order_line_id,

            CASE
                WHEN TRY_CAST(unit_price AS FLOAT) IS NULL
                THEN 'INVALID_UNIT_PRICE'
            END AS rule_order_line_unit_price
        FROM bronze.order_lines
    )
    SELECT *,
        NULLIF(CONCAT_WS('|', rule_order_line_id, rule_order_line_unit_price), '') AS error_reason
    FROM validated
) t;
