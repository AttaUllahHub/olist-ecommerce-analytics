from pathlib import Path
import duckdb

ROOT = Path(__file__).resolve().parent.parent
DB_PATH = ROOT / "olist.duckdb"


def build():
    if DB_PATH.exists():
        DB_PATH.unlink()
    con = duckdb.connect(str(DB_PATH))
    for name in ["01_schema.sql", "02_views.sql"]:
        con.execute((ROOT / "sql" / name).read_text())
    return con


if __name__ == "__main__":
    import os
    os.chdir(ROOT)
    con = build()
    for t in ["customers", "orders", "order_items", "order_payments", "order_reviews", "products", "sellers", "category_translation"]:
        print(f"{t:22s}{con.execute(f'SELECT COUNT(*) FROM {t}').fetchone()[0]:>9,}")
    print(con.execute(open(ROOT / "sql/03_data_quality.sql").read()).fetchdf().to_string(index=False))
