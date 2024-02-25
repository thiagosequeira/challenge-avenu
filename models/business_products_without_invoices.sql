-- models/business_products_without_invoices.sql

WITH invoice_status AS (
  SELECT
    business_product_id,
    CASE
      WHEN COUNT(*) = SUM(CASE WHEN state = 'rejected' THEN 1 ELSE 0 END) THEN 'all rejected'
      ELSE 'other status'
    END AS status
  FROM
    my_db.my_schema_replica_prod.invoice_advance
  WHERE
    currency = 'USD'
  GROUP BY
    business_product_id
),
business_product_with_status AS (
  SELECT
    bp.id AS business_product_id,
    COALESCE(s.status, 'no invoices') AS status
  FROM
    my_db.my_schema_replica_prod.business_product bp
  LEFT JOIN
    invoice_status s ON bp.id = s.business_product_id
  WHERE
    bp.product_name = 'invoice advance'
)
SELECT
  b.*,
  COALESCE(bpws.status, 'no invoices') AS invoice_status
FROM
  my_db.my_schema_replica_prod.business_product b
LEFT JOIN
  business_product_with_status bpws ON b.id = bpws.business_product_id