# Reportería mensual para pymes - plantilla SQL

Plantilla abierta de [Verum Data](https://verumdata.cl), consultora de BI y reportería en Santiago, Chile. Sirve para armar los tres reportes que casi toda pyme necesita cada mes, a partir de las ventas y los pagos que ya registra su sistema:

1. **Ventas del mes**: cuánto se vendió, por mes, por producto o servicio y por cliente.
2. **Cobranza**: qué está facturado y no pagado, con su antigüedad desde el vencimiento.
3. **Cierre de mes**: vendido, cobrado y pendiente, en una sola tabla por mes.

## Cómo se usa

1. Cargue sus datos en dos tablas con la forma de [`sql/01_tablas.sql`](sql/01_tablas.sql): `documentos` (facturas, boletas y notas de crédito) y `pagos`. Casi cualquier ERP o planilla exporta algo parecido.
2. Cree las vistas de [`sql/02_vistas.sql`](sql/02_vistas.sql).
3. Conecte a las vistas su herramienta de paneles (Data Studio, Power BI o una planilla).

La carpeta [`datos-ejemplo/`](datos-ejemplo/) trae datos inventados, y `probar.py` carga todo en SQLite y muestra las tres vistas: `python probar.py`.

El SQL está probado en SQLite; en SQL Server o BigQuery cambian solo las funciones de fecha, indicadas en los comentarios.

## Criterios que conviene dejar escritos

Un reporte confiable depende menos del gráfico que de acordar qué significa cada número. La plantilla fija estos criterios, y cada empresa debería revisar si le sirven:

- La venta se cuenta en la **fecha de emisión** del documento, sin IVA.
- Las notas de crédito restan en el mes en que se emiten.
- Un documento está **pagado** cuando la suma de sus pagos alcanza su total con IVA.
- La antigüedad de la deuda se cuenta desde la **fecha de vencimiento**, no desde la emisión.

## Sobre Verum Data

Verum Data conecta los sistemas que una empresa ya usa, ordena esa información en un solo lugar y entrega paneles de gestión e informes que se actualizan solos. Más información en [verumdata.cl/reporteria-pymes-santiago](https://verumdata.cl/reporteria-pymes-santiago).

Licencia MIT: puede usar, copiar y adaptar esta plantilla libremente.
