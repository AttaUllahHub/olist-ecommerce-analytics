import os
from pathlib import Path
import duckdb
import pandas as pd

ROOT = Path(__file__).resolve().parent.parent
os.chdir(ROOT)
from src.build_database import build

OUT = ROOT / "reports" / "results"


def main(show=True):
    OUT.mkdir(parents=True, exist_ok=True)
    con = build()
    dq = con.execute((ROOT / "sql/03_data_quality.sql").read_text()).fetchdf()
    dq.to_csv(OUT / "03_data_quality.csv", index=False)
    results = {"03_data_quality": dq}
    for path in sorted((ROOT / "sql" / "analysis").glob("*.sql")):
        df = con.execute(path.read_text()).fetchdf()
        df.to_csv(OUT / f"{path.stem}.csv", index=False)
        results[path.stem] = df
        if show:
            print(f"\n=== {path.stem} ({len(df)} rows) ===")
            print(df.head(12).to_string(index=False))
    con.close()
    return results


if __name__ == "__main__":
    main()
