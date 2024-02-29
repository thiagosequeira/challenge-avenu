# Consideraciones, procedimiento y raciocinio

**1. Ingestar los csv que se encuentren dentro de la carpeta de la carpeta Seeds.**

**2. Ingestar las rows de los archivos business y customer ddl, estos tienen un pequeño error de tipo de dato a solucionar para que puedan funcionar, el address es un string y la tabla espera un variant, respetando la metadata de las tablas se espera que se puedan insertar las rows (manteniendo el formato variant).**

Mi primer paso después de crear las cuentas en Snowflake y DBT, y posteriormente haber comprobado las conexiones, fue ingresar los datos en Snowflake. Al notar el tipo de error de datos que tenían los archivos .sql, 
procedí a cambiar el tipo de dato para que aceptara el formato JSON que la tabla espera, utilizando la cláusula "PARSE_JSON()".

Antes de comenzar a desarrollar el código de las siguientes consignas, tomé un tiempo para interpretar y aprender cómo están relacionadas las tablas, 
entender el negocio y qué se espera. Para ello, me guié con la siguiente imagen de las relaciones y las descripciones proporcionadas en el archivo principal.

![image](https://github.com/thiagosequeira/challenge-avenu/assets/73362049/a29210ef-734e-4bc9-8b93-d76870c14d5a)

**3. El área de operaciones de la compañía necesita lo siguiente:**
   - Monto de adelantos solicitados por cada uno de los business, esto es sumatoria del campo effective_advance cuando el advance date no es nulo y el estado no es rejected, imputado a la fecha del advance_date.
   - Monto de dinero que se ha devuelto, esto es sumatoria del campo effective_collections, siempre que el estado del invoice advance no sea rejected, imputado a la fecha del advace_date.
   - Monto de dinero debido a los fee del dinero adelantado, esto es sumatoria del campo fee_at_due imputado al due_date, siempre que el invoice advance no sea rejected.
   - Estos campos les gustaría poder hacer la apertura hasta un nivel de granularidad de día, business; pero también poder agrupar por semana o mes.
     
**4. El área de riesgo de la compañía necesita la siguiente información a obtener sobre la entidad invoices:**
  - Monto de facturas emitidas según el tipo, es decir monto de ingresos, egresos, pagos, pagos nóminas y transferencias de mercadería. Despreciar las invoices no vigentes.
  - Le gustaría tener esta información con un nivel de detalle de día y receiver_name, pero también poder agrupar por semana y mes.

Observé que en estos pasos se requería información de la tabla "business" para obtener el "business_id" y así relacionarlo con la tabla "invoice_advance" para obtener los datos necesarios. 
En lugar de realizar el join aparentemente necesario, decidí implementarlo con la foreign key de la tabla "invoice_advance" con el mismo nombre, "business_id". 
De esta manera, ahorré tiempo de procesamiento al ejecutar la consulta. Después de esto, continué con los filtros y la manipulación necesaria.

A la hora de hacer la apertura de día business, semana y mes, decidí aplicar las cláusulas WEEK(), MONTH(), y DATE_PART('dow') para los días laborables, que devuelve 0 = Domingo, ..., 6 = Sábado.

**5. Presentar un gráfico para el equipo de operaciones y uno para el equipo de riesgo con los KPI’s descritos anteriormente en un Power BI Desktop file (.pbix).**

Cada consigna anterior la encaré como individual, por eso realicé una bajada por cada query, y las relacioné dentro de Power BI con tablas de Dimensiones. 
En Power Query, realicé algunas manipulaciones de datos, como cambiar los números de los días laborables por los nombres correspondientes.

**6. En DBT, resolver mediante SQL los siguientes requerimientos:**
   - Se desea obtener el issuer_rfc que no haya emitido invoices de tipo I durante 3 meses consecutivos o más en los últimos 24 meses, junto con los meses consecutivos en los cuales eso sucedió.
   - Listado de todos los business existentes, con la cantidad de business_product de tipo invoice advance activos creados en 2021 y 2022; siempre y cuando haya tenido al menos 1 por cada año, de lo contrario mostrar 0.
   - Listado de TODOS los business_product de tipo Invoice Advance que NO tengan invoice_advance o que los que tiene sean todos rejected. Solo considerar los invoice advance en USD.
  
Ya que fue la primera vez que desarrollo en DBT, este punto fue el reto para mi. Me tocó investigar, leer documentación, aprender y probar.

### Explicación por punto:

**Query 1:**

- Generé una consulta común (CTE) llamada "invoice_status" para calcular el estado de las facturas asociadas a cada producto de negocio (business_product_id).
Dividí las facturas en dos categorías: "all rejected" si todas las facturas están rechazadas y "other status" para cualquier otro estado.
- Luego, utilicé otra CTE llamada "business_product_with_status" para vincular cada producto de negocio con su respectivo estado de factura.
Esta CTE maneja casos donde no hay facturas asociadas ('no invoices') y utiliza la función COALESCE para manejar valores nulos.
- Finalmente, la consulta principal realiza una unión entre la tabla de productos de negocio (business_product) y la tabla de productos de negocio con su estado calculado (business_product_with_status).

**Query 2:**

- Generé un CTE para calcular la cantidad de adelantos de facturas por negocio para los años 2021 y 2022. Utilicé la función SUM junto con CASE WHEN para contar los adelantos de facturas para cada año.
Si el año de creación del adelanto coincide con 2021 o 2022, se cuenta como 1; de lo contrario, se cuenta como 0.
- El CTE agrupa los resultados por el ID del negocio.
- La consulta principal selecciona el ID del negocio (business_id) junto con la cantidad de adelantos para los años 2021 y 2022.
- Utiliza un LEFT JOIN con el CTE "business_invoice_advances" para unir los datos de adelantos por negocio. Aplico la función COALESCE para manejar los casos en los que un negocio no tiene adelantos para un año específico,
- asegurando que todos los negocios estén representados en el resultado final.

**Query 3:**

- Generé un CTE llamado "invoice_status" para determinar el estado de las facturas de adelanto para cada producto de negocio.
Utilicé una declaración CASE para evaluar si todas las facturas de adelanto asociadas a un producto de negocio están en estado 'rejected' o no.
Si todas las facturas están en estado 'rejected', se asigna el valor 'all rejected' al estado del producto; de lo contrario, se asigna 'other status'.
- Utilicé un segundo CTE llamado "business_product_with_status" para unir los productos de negocio con su estado determinado en el CTE anterior (invoice_status).
Utilicé la función COALESCE para manejar los casos en los que un producto de negocio no tiene facturas de adelanto asociadas, estableciendo el estado en 'no invoices' para asegurar que todos los productos de negocio estén representados en el resultado final.
- La consulta principal selecciona todos los campos de la tabla "business_product" y utiliza un LEFT JOIN con el CTE "business_product_with_status" para unir los productos de negocio con sus estados determinados.
Nuevamente, la función COALESCE se utiliza para manejar los casos en los que un producto de negocio no tiene un estado determinado.



