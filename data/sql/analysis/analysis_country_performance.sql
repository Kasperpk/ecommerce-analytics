-- Country performance summary with revenue concentration
-- Demonstrates: DENSE_RANK, cumulative SUM OVER, percentage of total, CASE for tiering
CREATE OR REPLACE VIEW gold.analysis_country_performance AS
WITH country_metrics AS (
    SELECT
        o.country
        ,COUNT(DISTINCT o.order_id)                                             AS order_count
        ,COUNT(DISTINCT o.customer_id)                                          AS customer_count
        ,SUM(CAST(f.quantity AS INT))                                           AS units_sold
        ,SUM(CAST(f.quantity AS INT) * CAST(f.unit_price AS DECIMAL(10,2)))     AS gross_revenue
        ,SUM(CAST(f.line_discount_amount AS DECIMAL(10,2)))                     AS total_discounts
        ,SUM(CAST(f.quantity AS INT) * CAST(f.unit_price AS DECIMAL(10,2)))
         - SUM(CAST(f.line_discount_amount AS DECIMAL(10,2)))                   AS net_revenue
        ,ROUND(
            SUM(CAST(f.quantity AS INT) * CAST(f.unit_price AS DECIMAL(10,2)))
            / NULLIF(COUNT(DISTINCT o.order_id), 0)
        , 2)                                                                    AS avg_order_value
    FROM gold.FactOrderLine f
    JOIN gold.DimOrder o ON o.order_sk = f.order_sk
    WHERE f.order_sk != -1
    GROUP BY o.country
)
SELECT
    country
    ,order_count
    ,customer_count
    ,units_sold
    ,gross_revenue
    ,net_revenue
    ,avg_order_value
    ,DENSE_RANK() OVER (ORDER BY net_revenue DESC)                              AS revenue_rank
    ,ROUND(net_revenue / NULLIF(SUM(net_revenue) OVER (), 0) * 100, 1)         AS pct_of_total
    ,ROUND(SUM(net_revenue) OVER (ORDER BY net_revenue DESC)
         / NULLIF(SUM(net_revenue) OVER (), 0) * 100, 1)                       AS cumulative_pct
    ,CASE
        WHEN SUM(net_revenue) OVER (ORDER BY net_revenue DESC)
             / NULLIF(SUM(net_revenue) OVER (), 0) <= 0.80 THEN 'A-tier'
        WHEN SUM(net_revenue) OVER (ORDER BY net_revenue DESC)
             / NULLIF(SUM(net_revenue) OVER (), 0) <= 0.95 THEN 'B-tier'
        ELSE 'C-tier'
    END                                                                         AS country_tier
FROM country_metrics
ORDER BY net_revenue DESC;
