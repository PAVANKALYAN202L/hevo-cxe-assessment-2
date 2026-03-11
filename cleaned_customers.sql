CREATE TABLE DW_HEVO.PUBLIC.cleaned_customers AS
WITH ranked AS (
    SELECT *,
        ROW_NUMBER() OVER (
            PARTITION BY customer_id 
            ORDER BY updated_at DESC NULLS LAST
        ) AS rn
    FROM DW_HEVO.PUBLIC.customers_raw
)
SELECT
    customer_id,
    CASE 
        WHEN email IS NULL THEN 'Invalid Customer'
        ELSE LOWER(email)
    END AS email,
    CASE 
        WHEN phone IS NULL THEN 'Unknown'
        WHEN LENGTH(REGEXP_REPLACE(phone, '[^0-9]', '')) != 10 THEN 'Unknown'
        ELSE REGEXP_REPLACE(phone, '[^0-9]', '')
    END AS phone,
    CASE 
        WHEN UPPER(REPLACE(country_code,' ','')) IN ('US','USA','UNITEDSTATES') THEN 'US'
        WHEN UPPER(country_code) IN ('IN','IND','INDIA') THEN 'IN'
        WHEN UPPER(country_code) IN ('SG','SINGAPORE') THEN 'SG'
        WHEN country_code IS NULL THEN 'Unknown'
        ELSE 'Unknown'
    END AS country_code,
    COALESCE(created_at, '1900-01-01'::TIMESTAMP) AS created_at,
    updated_at,
    CASE
        WHEN customer_id IS NULL AND email IS NULL 
          AND phone IS NULL AND country_code IS NULL 
        THEN 'Invalid Customer'
        ELSE 'Valid'
    END AS customer_status
FROM ranked
WHERE rn = 1;