CREATE OR REPLACE VIEW gold.FactOrderLine AS
SELECT
	COALESCE(p.product_sk, -1) AS product_sk
	,COALESCE(o.order_sk, -1) AS order_sk
	,ol.quantity
	,ol.unit_price
	,ol.line_ts
	,ol.sku
	,ol.line_discount_amount
	,ol.tax_rate
	,ol.new_fulfillment_mode
FROM silver.order_lines ol
LEFT JOIN gold.DimProduct p ON p.product_id = ol.product_id
LEFT JOIN gold.DimOrder o ON o.order_id = ol.order_id;
