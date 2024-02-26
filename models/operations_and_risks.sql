-- models/operations_and_risks.sql

-- Requerimiento 1

SELECT 
    business_id,
    SUM(effective_advance) AS monto_adelantos
FROM 
    MY_DB.MY_SCHEMA_REPLICA_PROD.INVOICE_ADVANCE
WHERE 
    advance_date IS NOT NULL
    AND state <> 'rejected'
GROUP BY 
    business_id;

-- Requerimiento 2
    
SELECT
    business_id,
    SUM(effective_collection) AS dinero_devuelto
FROM
    MY_DB.MY_SCHEMA_REPLICA_PROD.INVOICE_ADVANCE
WHERE
    state != 'rejected'
    AND advance_date IS NOT NULL
GROUP BY
    business_id;

-- Requerimiento 3
    
SELECT
    business_id,
    SUM(fee_at_due) AS monto_debido
FROM
    MY_DB.MY_SCHEMA_REPLICA_PROD.INVOICE_ADVANCE
WHERE
    due_date IS NOT NULL
    AND state != 'rejected'
GROUP BY
    business_id;

-- Requerimiento 4

-- a)

SELECT
    business_id,
    SUM(effective_advance) AS monto_adelantos,
    DATE_PART('dow', advance_date) AS business_day, -- (LUNES = 1, SABADO = 6, DOMINGO = 7)
    WEEK(advance_date) week,
    YEAR(advance_date) year
FROM
    MY_DB.MY_SCHEMA_REPLICA_PROD.INVOICE_ADVANCE
WHERE 
    advance_date IS NOT NULL
    AND state <> 'rejected'
GROUP BY
    business_id, business_day, week, year;

-- b)

SELECT
    business_id,
    SUM(effective_collection) AS dinero_devuelto,
    DATE_PART('dow', advance_date) AS business_day, -- (LUNES = 1, SABADO = 6, DOMINGO = 7)
    WEEK(advance_date) week,
    YEAR(advance_date) year
FROM
    MY_DB.MY_SCHEMA_REPLICA_PROD.INVOICE_ADVANCE
WHERE
    state != 'rejected'
    AND advance_date IS NOT NULL
GROUP BY
    business_id, business_day, week, year;

-- c)

SELECT
    business_id,
    SUM(fee_at_due) AS monto_debido,
    DATE_PART('dow', due_date) AS business_day, -- (LUNES = 1, SABADO = 6, DOMINGO = 7)
    WEEK(due_date) week,
    YEAR(due_date) year
FROM
    MY_DB.MY_SCHEMA_REPLICA_PROD.INVOICE_ADVANCE
WHERE
    due_date IS NOT NULL
    AND state != 'rejected'
GROUP BY
    business_id, business_day, week, year;

-- Requerimiento 5 

SELECT
    type,
    SUM(total) AS total_amount
FROM
    MY_DB.MY_SCHEMA_REPLICA_PROD.INVOICES
WHERE
    status = 'VIGENTE'
GROUP BY
    type;

-- Requerimiento 6

SELECT
    type,
    receiver_name,
    SUM(total) AS total_amount,
    WEEK(issued_at) week,
    YEAR(issued_at) year
FROM
    MY_DB.MY_SCHEMA_REPLICA_PROD.INVOICES
WHERE
    status = 'VIGENTE'
GROUP BY
    type, receiver_name, week, year;