CREATE OR REPLACE TABLE silver.refunds AS
SELECT
	r.refund_id
	,r.order_line_id
	,r.order_id
	,r.refund_ts
	,r.refund_amount
	,r.refund_status
	,r.refund_reason
	,r.new_refund_processor
	,r.new_case_id
	,r.filename
	,r.dt
FROM
	(SELECT
	refund_id
	,order_line_id
	,order_id
	,refund_ts
	,refund_amount
	,refund_status
	,refund_reason
	,new_refund_processor
	,new_case_id
	,filename
	,dt
	,error_reason
	,ROW_NUMBER() over (Partition by refund_id order by dt desc) as _rn
	FROM transform.refunds_validated
	WHERE error_reason IS NULL
	) r
WHERE r._rn = 1;
