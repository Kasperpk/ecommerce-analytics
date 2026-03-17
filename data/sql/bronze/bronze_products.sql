CREATE OR REPLACE TABLE bronze.products AS
SELECT *
FROM read_csv('data/raw/dt=*/products.csv',
    union_by_name = true,
    filename = true,
    all_varchar = true,
    ignore_errors = true,
    null_padding = true,
    delim = ',',
    strict_mode = false
);