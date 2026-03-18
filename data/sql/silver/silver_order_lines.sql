CREATE OR REPLACE TABLE silver.order_lines AS
SELECT
	ol.order_line_id
	,ol.product_id
	,ol.order_id
	,ol.quantity
	,ol.unit_price
	,ol.line_ts
	,ol.sku
	,ol.line_discount_amount
	,ol.tax_rate
	,ol.new_fulfillment_mode
	,ol.filename
	,ol.dt
FROM
	(SELECT
	order_line_id
	,order_id
	,product_id
	,quantity
	,unit_price
	,line_ts
	,sku
	,line_discount_amount
	,tax_rate
	,new_fulfillment_mode
	,filename
	,dt
	,error_reason
	,ROW_NUMBER() over (Partition by order_line_id order by dt desc) as _rn
	FROM transform.order_lines_validated
	WHERE error_reason IS NULL
	) ol
WHERE ol._rn = 1;
