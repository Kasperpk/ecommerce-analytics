CREATE OR REPLACE VIEW gold.DimOrder AS
SELECT
	ROW_NUMBER() OVER (ORDER BY order_id) AS order_sk
	,order_id
	,customer_id
	,order_ts
	,country
	,currency
	,payment_method
	,shipping_amount
	,discount_amount
	,order_status
	,source_file_date
	,new_device_type
	,new_marketing_channel
FROM silver.orders;
