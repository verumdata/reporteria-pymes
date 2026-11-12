-- Tablas de entrada: una fila por documento y una por pago.
-- tipo: 'FAC' factura, 'BOL' boleta, 'NC' nota de crédito (monto positivo; las vistas lo restan).

CREATE TABLE documentos (
    id_documento      INTEGER PRIMARY KEY,
    tipo              VARCHAR(3)    NOT NULL,
    folio             INTEGER       NOT NULL,
    fecha_emision     DATE          NOT NULL,
    fecha_vencimiento DATE          NOT NULL,
    cliente           VARCHAR(100)  NOT NULL,
    producto          VARCHAR(100)  NOT NULL,
    monto_neto        DECIMAL(14,0) NOT NULL,
    monto_total       DECIMAL(14,0) NOT NULL  -- con IVA
);

CREATE TABLE pagos (
    id_pago      INTEGER PRIMARY KEY,
    id_documento INTEGER       NOT NULL REFERENCES documentos (id_documento),
    fecha_pago   DATE          NOT NULL,
    monto        DECIMAL(14,0) NOT NULL
);
