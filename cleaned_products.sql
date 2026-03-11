CREATE TABLE DW_HEVO.PUBLIC.cleaned_products AS
SELECT
    product_id,
    CASE 
        WHEN active_flag = 'N' THEN 'Discontinued Product'
        ELSE INITCAP(product_name)
    END AS product_name,
    INITCAP(category) AS category,
    active_flag
FROM DW_HEVO.PUBLIC.products_raw;