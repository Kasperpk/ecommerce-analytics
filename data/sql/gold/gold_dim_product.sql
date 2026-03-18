CREATE OR REPLACE VIEW gold.DimProduct AS
SELECT
	ROW_NUMBER() OVER (ORDER BY product_id) AS product_sk
	,product_id
	,sku
	,product_name
	,product_type
	,cost_price
	,list_price
	,brand
	,is_active
	,currency
	,category
FROM silver.products;
