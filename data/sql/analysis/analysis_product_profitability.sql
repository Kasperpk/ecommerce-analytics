-- Revenue by product category with margin analysis and ranking
-- Demonstrates: CTE, window functions (RANK, SUM OVER), CASE expressions, margin calculation
CREATE OR REPLACE VIEW gold.analysis_product_profitability AS
WITH product_revenue AS (
    SELECT
        p.product_type
        ,p.brand
        ,p.product_name
        ,p.product_id
        ,CAST(p.cost_price AS DECIMAL(10,2)) AS cost_price
        ,CAST(p.list_price AS DECIMAL(10,2)) AS list_price
        ,SUM(CAST(f.quantity AS INT))                                           AS units_sold
        ,SUM(CAST(f.quantity AS INT) * CAST(f.unit_price AS DECIMAL(10,2)))     AS gross_revenue
        ,SUM(CAST(f.line_discount_amount AS DECIMAL(10,2)))                     AS total_discounts
        ,SUM(CAST(f.quantity AS INT) * CAST(f.unit_price AS DECIMAL(10,2)))
         - SUM(CAST(f.line_discount_amount AS DECIMAL(10,2)))                   AS net_revenue
        ,SUM(CAST(f.quantity AS INT) * CAST(p.cost_price AS DECIMAL(10,2)))     AS total_cost
    FROM gold.FactOrderLine f
    JOIN gold.DimProduct p ON p.product_sk = f.product_sk
    WHERE f.product_sk != -1
    GROUP BY p.product_type, p.brand, p.product_name, p.product_id,
             p.cost_price, p.list_price
)
SELECT
    *
    ,net_revenue - total_cost                                                   AS gross_profit
    ,ROUND((net_revenue - total_cost) / NULLIF(net_revenue, 0) * 100, 1)       AS margin_pct
    ,RANK() OVER (PARTITION BY product_type ORDER BY net_revenue DESC)          AS revenue_rank_in_category
    ,ROUND(net_revenue / NULLIF(SUM(net_revenue) OVER (), 0) * 100, 2)         AS pct_of_total_revenue
FROM product_revenue;
