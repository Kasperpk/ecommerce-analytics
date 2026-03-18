-- Daily revenue with 7-day moving average and period-over-period growth
-- Demonstrates: window functions (AVG OVER ROWS BETWEEN), LAG, DATE_TRUNC, COALESCE
CREATE OR REPLACE VIEW gold.analysis_daily_revenue AS
WITH daily AS (
    SELECT
        CAST(o.order_ts AS DATE)                                                AS order_date
        ,COUNT(DISTINCT o.order_id)                                             AS order_count
        ,SUM(CAST(f.quantity AS INT))                                           AS units_sold
        ,SUM(CAST(f.quantity AS INT) * CAST(f.unit_price AS DECIMAL(10,2)))     AS gross_revenue
        ,SUM(CAST(f.line_discount_amount AS DECIMAL(10,2)))                     AS total_discounts
        ,SUM(CAST(f.quantity AS INT) * CAST(f.unit_price AS DECIMAL(10,2)))
         - SUM(CAST(f.line_discount_amount AS DECIMAL(10,2)))                   AS net_revenue
    FROM gold.FactOrderLine f
    JOIN gold.DimOrder o ON o.order_sk = f.order_sk
    WHERE f.order_sk != -1
    GROUP BY CAST(o.order_ts AS DATE)
)
SELECT
    order_date
    ,order_count
    ,units_sold
    ,gross_revenue
    ,total_discounts
    ,net_revenue
    ,ROUND(AVG(net_revenue) OVER (
        ORDER BY order_date
        ROWS BETWEEN 6 PRECEDING AND CURRENT ROW
    ), 2)                                                                       AS net_revenue_7d_ma
    ,LAG(net_revenue) OVER (ORDER BY order_date)                                AS prev_day_revenue
    ,ROUND(
        (net_revenue - LAG(net_revenue) OVER (ORDER BY order_date))
        / NULLIF(LAG(net_revenue) OVER (ORDER BY order_date), 0) * 100
    , 1)                                                                        AS revenue_dod_growth_pct
FROM daily
ORDER BY order_date;
