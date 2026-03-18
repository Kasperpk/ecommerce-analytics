-- Customer segmentation: order frequency, spend tiers, and lifetime value
-- Demonstrates: multi-level CTEs, NTILE, CASE, window functions, complex aggregation
CREATE OR REPLACE VIEW gold.analysis_customer_segments AS
WITH customer_orders AS (
    SELECT
        o.customer_id
        ,COUNT(DISTINCT o.order_id)                                             AS order_count
        ,MIN(CAST(o.order_ts AS DATE))                                         AS first_order_date
        ,MAX(CAST(o.order_ts AS DATE))                                         AS last_order_date
        ,DATEDIFF('day', MIN(CAST(o.order_ts AS DATE)),
                         MAX(CAST(o.order_ts AS DATE)))                         AS customer_tenure_days
        ,SUM(CAST(f.quantity AS INT) * CAST(f.unit_price AS DECIMAL(10,2)))     AS lifetime_gross_revenue
        ,SUM(CAST(f.line_discount_amount AS DECIMAL(10,2)))                     AS lifetime_discounts
        ,SUM(CAST(f.quantity AS INT) * CAST(f.unit_price AS DECIMAL(10,2)))
         - SUM(CAST(f.line_discount_amount AS DECIMAL(10,2)))                   AS lifetime_net_revenue
        ,SUM(CAST(f.quantity AS INT))                                           AS lifetime_units
    FROM gold.DimOrder o
    JOIN gold.FactOrderLine f ON f.order_sk = o.order_sk
    WHERE f.product_sk != -1
    GROUP BY o.customer_id
),
segmented AS (
    SELECT
        *
        ,ROUND(lifetime_net_revenue / NULLIF(order_count, 0), 2)               AS avg_order_value
        ,NTILE(4) OVER (ORDER BY lifetime_net_revenue)                          AS spend_quartile
        ,CASE
            WHEN order_count = 1                              THEN 'One-time'
            WHEN order_count BETWEEN 2 AND 3                  THEN 'Occasional'
            WHEN order_count >= 4                             THEN 'Frequent'
        END                                                                     AS frequency_segment
    FROM customer_orders
)
SELECT
    *
    ,CASE spend_quartile
        WHEN 1 THEN 'Low'
        WHEN 2 THEN 'Medium-Low'
        WHEN 3 THEN 'Medium-High'
        WHEN 4 THEN 'High'
    END                                                                         AS spend_tier
FROM segmented
ORDER BY lifetime_net_revenue DESC;
