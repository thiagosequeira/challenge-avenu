# Challenge Técnico - Avenu Learning 

## Objetivo
Evaluar los conocimientos del candidato en relación con la posición de Data Analyst. Los aspectos que se desean evaluar son los siguientes:
- Modelado de Datos
- ETL
- Buenas prácticas de ingeniería
- SQL querys y funciones
- Visualización en Power BI

## Enunciado
- Ingestar los csv que se encuentren dentro de la carpeta de la carpeta Seeds.
- Ingestar las rows de los archivos business y customer ddl, estos tienen un pequeño error de tipo de dato a solucionar para que puedan funcionar, el address es un string y la tabla espera un variant, respetando la metadata de las tablas se espera que se puedan insertar las rows (manteniendo el formato variant).

- Modelar los datos de la manera necesaria, contemplando las reglas de integridad y/o calidad de datos; siguiendo las buenas prácticas para soportar los siguientes requerimientos:
  - El área de operaciones de la compañía necesita lo siguiente:
    - Monto de adelantos solicitados por cada uno de los business, esto es sumatoria del campo effective_advance cuando el advance date no es nulo y el estado no es rejected, imputado a la fecha del advance_date.
    - Monto de dinero que se ha devuelto, esto es sumatoria del campo effective_collections, siempre que el estado del invoice advance no sea rejected, imputado a la fecha del advace_date.
    - Monto de dinero debido a los fee del dinero adelantado, esto es sumatoria del campo fee_at_due imputado al due_date, siempre que el invoice advance no sea rejected.
    - Estos campos les gustaría poder hacer la apertura hasta un nivel de granularidad de día, business; pero también poder agrupar por semana o mes.
  - El área de riesgo de la compañía necesita la siguiente información a obtener sobre la entidad invoices:
    - Monto de facturas emitidas según el tipo, es decir monto de ingresos, egresos, pagos, pagos nóminas y transferencias de mercadería. Despreciar las invoices no vigentes.
    - Le gustaría tener esta información con un nivel de detalle de día y receiver_name, pero también poder agrupar por semana y mes.
- Presentar un gráfico para el equipo de operaciones y uno para el equipo de riesgo con los KPI’s descritos anteriormente en un Power BI Desktop file (.pbix).
- En DBT, resolver mediante SQL los siguientes requerimientos:
  - Se desea obtener el issuer_rfc que no haya emitido invoices de tipo I durante 3 meses consecutivos o más en los últimos 24 meses, junto con los meses consecutivos en los cuales eso sucedió.
  - Listado de todos los business existentes, con la cantidad de business_product de tipo invoice advance activos creados en 2021 y 2022; siempre y cuando haya tenido al menos 1 por cada año, de lo contrario mostrar 0.
  - Listado de TODOS los business_product de tipo Invoice Advance que NO tengan invoice_advance o que los que tiene sean todos rejected. Solo considerar los invoice advance en USD.

## Using the starter project

Try running the following commands:
- dbt run
- dbt test

## Resources:
- Learn more about dbt [in the docs](https://docs.getdbt.com/docs/introduction)
- Check out [Discourse](https://discourse.getdbt.com/) for commonly asked questions and answers
- Join the [dbt community](https://getdbt.com/community) to learn from other analytics engineers
- Find [dbt events](https://events.getdbt.com) near you
- Check out [the blog](https://blog.getdbt.com/) for the latest news on dbt's development and best practices

```
$PROJECT_ROOT
│   
├── analyses
│   
├── macros
│   # SQL instructions
├── models 
│   # CSV files
├── seeds
│  
├── snapshots
│ 
└── tests
```
