CREATE OR REPLACE TABLE transform.products_validated AS
SELECT * FROM (
    WITH validated AS (
        SELECT *,
            CASE
                WHEN SUBSTRING(product_id, 1, 1) != 'P' OR product_id IS NULL
                THEN 'INVALID_PRODUCT_ID'
            END AS rule_product_id,

            CASE
                WHEN TRY_CAST(list_price AS FLOAT) IS NULL
                THEN 'MISSING_LIST_PRICE'
            END AS rule_product_list_price
        FROM bronze.products
    )
    SELECT *,
        NULLIF(CONCAT_WS('|', rule_product_id, rule_product_list_price), '') AS error_reason
    FROM validated
) t;
