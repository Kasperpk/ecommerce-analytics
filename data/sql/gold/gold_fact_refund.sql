CREATE OR REPLACE VIEW gold.FactRefund AS
SELECT
	COALESCE(o.order_sk, -1) AS order_sk
	,r.refund_id
	,r.order_line_id
	,r.refund_ts
	,r.refund_amount
	,r.refund_status
	,r.refund_reason
	,r.new_refund_processor
	,r.new_case_id
FROM silver.refunds r
LEFT JOIN gold.DimOrder o ON o.order_id = r.order_id;
