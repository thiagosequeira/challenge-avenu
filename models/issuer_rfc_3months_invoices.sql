-- models/issuer_rfc_3months_invoices.sql

WITH RECURSIVE months AS (
  SELECT DATE_TRUNC('month', CURRENT_DATE()) AS month
  UNION ALL
  SELECT DATEADD('month', -1, month) FROM months WHERE month >= DATEADD('month', -24, CURRENT_DATE())
)

SELECT
  t.issuer_rfc,
  MIN(t.month) AS start_month,
  MAX(t.month) AS end_month
FROM (
  SELECT
    issuers.issuer_rfc,
    months.month,
    ROW_NUMBER() OVER (PARTITION BY issuers.issuer_rfc ORDER BY months.month) - ROW_NUMBER() OVER (PARTITION BY issuers.issuer_rfc, i.type ORDER BY months.month) AS grp
  FROM
    months
  CROSS JOIN
    (SELECT DISTINCT issuer_rfc FROM MY_DB.MY_SCHEMA_REPLICA_PROD.Invoices) issuers
  LEFT JOIN
    MY_DB.MY_SCHEMA_REPLICA_PROD.Invoices i ON i.issued_at >= months.month 
    AND i.issued_at < DATEADD('month', 1, months.month) 
    AND i.type = 'I' 
    AND i.issuer_rfc = issuers.issuer_rfc
  WHERE
    i.issued_at IS NULL
) t
GROUP BY
  t.issuer_rfc, t.grp
HAVING
  COUNT(*) >= 3