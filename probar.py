"""Carga los datos de ejemplo en SQLite en memoria y muestra las tres vistas."""
import csv
import pathlib
import sqlite3

RAIZ = pathlib.Path(__file__).parent
con = sqlite3.connect(":memory:")
con.executescript((RAIZ / "sql" / "01_tablas.sql").read_text(encoding="utf-8"))
for tabla in ("documentos", "pagos"):
    with open(RAIZ / "datos-ejemplo" / f"{tabla}.csv", encoding="utf-8") as f:
        filas = list(csv.DictReader(f))
    marcas = ",".join("?" * len(filas[0]))
    con.executemany(f"INSERT INTO {tabla} VALUES ({marcas})", [list(x.values()) for x in filas])
con.executescript((RAIZ / "sql" / "02_vistas.sql").read_text(encoding="utf-8"))
for vista in ("v_ventas_mes", "v_cobranza", "v_cierre_mes"):
    print(vista)
    for fila in con.execute(f"SELECT * FROM {vista}"):
        print("  ", fila)
