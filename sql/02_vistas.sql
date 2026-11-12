-- Vistas de reportería mensual.
-- Funciones de fecha en SQLite: strftime('%Y-%m', fecha) y julianday().
--   SQL Server: FORMAT(fecha, 'yyyy-MM') y DATEDIFF(day, a, b).
--   BigQuery:   FORMAT_DATE('%Y-%m', fecha) y DATE_DIFF(b, a, DAY).

-- 1. Ventas netas por mes, producto y cliente. Las notas de crédito restan.
CREATE VIEW v_ventas_mes AS
SELECT
    strftime('%Y-%m', fecha_emision) AS mes,
    producto,
    cliente,
    SUM(CASE WHEN tipo = 'NC' THEN -monto_neto ELSE monto_neto END) AS venta_neta,
    COUNT(*) AS documentos
FROM documentos
GROUP BY 1, 2, 3;

-- 2. Saldo de cada factura o boleta.
CREATE VIEW v_saldo_documento AS
SELECT
    d.id_documento,
    d.tipo,
    d.folio,
    d.cliente,
    d.fecha_emision,
    d.fecha_vencimiento,
    d.monto_total,
    COALESCE(SUM(p.monto), 0)                 AS pagado,
    d.monto_total - COALESCE(SUM(p.monto), 0) AS saldo
FROM documentos d
LEFT JOIN pagos p ON p.id_documento = d.id_documento
WHERE d.tipo <> 'NC'
GROUP BY d.id_documento, d.tipo, d.folio, d.cliente, d.fecha_emision,
         d.fecha_vencimiento, d.monto_total;

-- 3. Cobranza: documentos con saldo, por tramo de antigüedad desde el vencimiento.
--    Cambie date('now') por la fecha de corte del reporte si la necesita fija.
CREATE VIEW v_cobranza AS
SELECT
    cliente,
    folio,
    fecha_vencimiento,
    saldo,
    CAST(julianday(date('now')) - julianday(fecha_vencimiento) AS INTEGER) AS dias_vencido,
    CASE
        WHEN julianday(date('now')) - julianday(fecha_vencimiento) <= 0  THEN 'Por vencer'
        WHEN julianday(date('now')) - julianday(fecha_vencimiento) <= 30 THEN '1-30 días'
        WHEN julianday(date('now')) - julianday(fecha_vencimiento) <= 60 THEN '31-60 días'
        WHEN julianday(date('now')) - julianday(fecha_vencimiento) <= 90 THEN '61-90 días'
        ELSE 'Más de 90 días'
    END AS tramo
FROM v_saldo_documento
WHERE saldo > 0;

-- 4. Cierre de mes: vendido (con IVA), cobrado en el mes y pendiente de lo emitido ese mes.
CREATE VIEW v_cierre_mes AS
WITH vendido AS (
    SELECT strftime('%Y-%m', fecha_emision) AS mes,
           SUM(CASE WHEN tipo = 'NC' THEN -monto_total ELSE monto_total END) AS vendido
    FROM documentos
    GROUP BY 1
),
cobrado AS (
    SELECT strftime('%Y-%m', fecha_pago) AS mes, SUM(monto) AS cobrado
    FROM pagos
    GROUP BY 1
),
pendiente AS (
    SELECT strftime('%Y-%m', fecha_emision) AS mes, SUM(saldo) AS pendiente
    FROM v_saldo_documento
    GROUP BY 1
)
SELECT
    v.mes,
    v.vendido,
    COALESCE(c.cobrado, 0)   AS cobrado_en_el_mes,
    COALESCE(p.pendiente, 0) AS pendiente_de_lo_emitido
FROM vendido v
LEFT JOIN cobrado   c ON c.mes = v.mes
LEFT JOIN pendiente p ON p.mes = v.mes;
