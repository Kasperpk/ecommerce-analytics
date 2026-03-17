SELECT 'bronze.products' AS table_name, COUNT(*) AS row_count FROM bronze.products
UNION ALL
SELECT 'bronze.orders', COUNT(*) FROM bronze.orders
UNION ALL
SELECT 'bronze.order_lines', COUNT(*) FROM bronze.order_lines
UNION ALL
SELECT 'bronze.refunds', COUNT(*) FROM bronze.refunds;
