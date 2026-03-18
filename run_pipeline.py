#!/usr/bin/env python3
"""Run the full ELT pipeline: schemas → bronze → transform → data_quality → silver → gold → analysis."""
import glob
import duckdb

DB_PATH = "data/analytics.duckdb"

PIPELINE_STEPS = [
    ("Schemas",       ["data/sql/create_schemas.sql"]),
    ("Bronze",        sorted(glob.glob("data/sql/bronze/*.sql"))),
    ("Transform",     sorted(glob.glob("data/sql/transform/*.sql"))),
    ("Data Quality",  sorted(glob.glob("data/sql/data_quality/*.sql"))),
    ("Silver",        sorted(glob.glob("data/sql/silver/*.sql"))),
    ("Gold",          sorted(glob.glob("data/sql/gold/*.sql"))),
    ("Analysis",      sorted(glob.glob("data/sql/analysis/*.sql"))),
]


def run_sql_file(con, path):
    sql = open(path, encoding="utf-8").read()
    for statement in sql.split(";"):
        statement = statement.strip()
        if not statement:
            continue
        con.sql(statement)


def main():
    con = duckdb.connect(DB_PATH)
    for step_name, files in PIPELINE_STEPS:
        if not files:
            continue
        print(f"\n{'='*60}")
        print(f"  {step_name}")
        print(f"{'='*60}")
        for f in files:
            print(f"  ✓ {f}")
            run_sql_file(con, f)
    con.close()
    print(f"\n{'='*60}")
    print("  Pipeline complete.")
    print(f"{'='*60}")


if __name__ == "__main__":
    main()
