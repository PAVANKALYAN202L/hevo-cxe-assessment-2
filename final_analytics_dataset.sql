CREATE TABLE DW_HEVO.PUBLIC.final_analytics_dataset AS
SELECT
    o.order_id,
    o.customer_id,
    COALESCE(c.email, 'Orphan Customer') AS customer_email,
    COALESCE(c.phone, 'Unknown') AS phone,
    COALESCE(c.country_code, 'Unknown') AS country_code,
    o.product_id,
    COALESCE(p.product_name, 'Unknown Product') AS product_name,
    COALESCE(p.category, 'Unknown') AS category,
    o.amount,
    o.amount_usd,
    o.currency,
    o.created_at,
    CASE 
        WHEN c.customer_id IS NULL THEN 'Invalid Customer'
        WHEN c.customer_status = 'Invalid Customer' THEN 'Invalid Customer'
        ELSE 'Valid Customer'
    END AS customer_status
FROM DW_HEVO.PUBLIC.cleaned_orders o
LEFT JOIN DW_HEVO.PUBLIC.cleaned_customers c ON o.customer_id = c.customer_id
LEFT JOIN DW_HEVO.PUBLIC.cleaned_products p ON o.product_id = p.product_id;