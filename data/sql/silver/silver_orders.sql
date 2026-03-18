CREATE OR REPLACE TABLE silver.orders AS
SELECT
	o.order_id
	,o.customer_id
	,o.order_ts
	,o.country
	,o.currency
	,o.payment_method
	,o.shipping_amount
	,o.discount_amount
	,o.order_status
	,o.source_file_date
	,o.new_device_type
	,o.new_marketing_channel
	,o.filename
	,o.dt
FROM
	(SELECT
	order_id
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
	,filename
	,dt
	,error_reason
	,ROW_NUMBER() over (Partition by order_id order by dt desc) as _rn
	FROM transform.orders_validated
	WHERE error_reason IS NULL
	) o
WHERE o._rn = 1;
