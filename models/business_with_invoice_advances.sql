-- models/business_with_invoice_advances.sql

WITH business_invoice_advances AS (
  SELECT
    b.id AS business_id,
    SUM(CASE WHEN EXTRACT(YEAR FROM bp.created_at) = 2021 THEN 1 ELSE 0 END) AS advances_2021,
    SUM(CASE WHEN EXTRACT(YEAR FROM bp.created_at) = 2022 THEN 1 ELSE 0 END) AS advances_2022
  FROM
    my_db.my_schema_replica_prod.business b
  LEFT JOIN
    my_db.my_schema_replica_prod.business_product bp ON b.id = bp.business_id
    AND bp.product_name = 'Invoice advance'
  WHERE
    EXTRACT(YEAR FROM bp.created_at) IN (2021, 2022)
  GROUP BY
    b.id
)
SELECT
  b.id AS business_id,
  COALESCE(advances_2021, 0) AS advances_2021,
  COALESCE(advances_2022, 0) AS advances_2022
FROM
  my_db.my_schema_replica_prod.business b
LEFT JOIN
  business_invoice_advances bia ON b.id = bia.business_id