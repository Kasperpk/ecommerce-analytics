CREATE OR REPLACE TABLE silver.products AS
SELECT
	p.product_id
	,p.sku
	,p.product_name
	,p.product_type
	,p.cost_price
	,p.list_price
	,p.brand
	,p.is_active
	,p.currency
	,p.category
	,p.created_at
	,p.filename
	,p.dt
FROM
	(SELECT product_id
	,sku
	,product_name
	,product_type
	,cost_price
	,list_price
	,brand
	,is_active
	,currency
	,category
	,created_at
	,filename
	,dt
	,error_reason
	,ROW_NUMBER() over (Partition by product_id order by dt desc) as _rn
	FROM transform.products_validated
	WHERE error_reason IS NULL
	) p
WHERE p._rn = 1;
