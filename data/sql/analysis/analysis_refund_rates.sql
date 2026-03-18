-- Refund rate analysis by product type and country
-- Demonstrates: multi-table JOIN, conditional aggregation (COUNT with FILTER), HAVING, ROUND
CREATE OR REPLACE VIEW gold.analysis_refund_rates AS
WITH order_line_refunds AS (
    SELECT
        p.product_type
        ,p.brand
        ,o.country
        ,o.payment_method
        ,COUNT(DISTINCT f.order_sk || '-' || f.product_sk)                      AS total_lines
        ,COUNT(DISTINCT r.refund_id)                                            AS refund_count
        ,SUM(CAST(f.quantity AS INT) * CAST(f.unit_price AS DECIMAL(10,2)))     AS line_revenue
        ,COALESCE(SUM(CAST(r.refund_amount AS DECIMAL(10,2))), 0)              AS refund_amount
    FROM gold.FactOrderLine f
    JOIN gold.DimProduct p ON p.product_sk = f.product_sk
    JOIN gold.DimOrder o ON o.order_sk = f.order_sk
    LEFT JOIN gold.FactRefund r ON r.order_sk = f.order_sk
    WHERE f.product_sk != -1 AND f.order_sk != -1
    GROUP BY p.product_type, p.brand, o.country, o.payment_method
)
SELECT
    product_type
    ,brand
    ,country
    ,payment_method
    ,total_lines
    ,refund_count
    ,ROUND(refund_count::FLOAT / NULLIF(total_lines, 0) * 100, 1)              AS refund_rate_pct
    ,line_revenue
    ,refund_amount
    ,ROUND(refund_amount / NULLIF(line_revenue, 0) * 100, 1)                   AS refund_value_pct
FROM order_line_refunds
ORDER BY refund_rate_pct DESC;
