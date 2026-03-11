CREATE TABLE DW_HEVO.PUBLIC.cleaned_orders AS
WITH deduped AS (
    SELECT DISTINCT * FROM DW_HEVO.PUBLIC.orders_raw
),
median_calc AS (
    SELECT 
        customer_id,
        MEDIAN(amount) AS median_amount
    FROM deduped
    WHERE amount IS NOT NULL AND amount > 0
    GROUP BY customer_id
)
SELECT
    d.order_id,
    d.customer_id,
    d.product_id,
    CASE 
        WHEN d.amount IS NULL THEN COALESCE(m.median_amount, 0)
        WHEN d.amount < 0 THEN 0
        ELSE d.amount
    END AS amount,
    d.created_at,
    UPPER(COALESCE(d.currency, 'UNKNOWN')) AS currency,
    CASE 
        WHEN UPPER(d.currency) = 'USD' THEN GREATEST(COALESCE(d.amount, 0), 0)
        WHEN UPPER(d.currency) = 'INR' THEN GREATEST(COALESCE(d.amount, 0), 0) * 0.012
        WHEN UPPER(d.currency) = 'SGD' THEN GREATEST(COALESCE(d.amount, 0), 0) * 0.74
        WHEN UPPER(d.currency) = 'EUR' THEN GREATEST(COALESCE(d.amount, 0), 0) * 1.08
        ELSE GREATEST(COALESCE(d.amount, 0), 0)
    END AS amount_usd
FROM deduped d
LEFT JOIN median_calc m ON d.customer_id = m.customer_id;