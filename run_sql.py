#!/usr/bin/env python3
import sys
import duckdb

DB_PATH = "data/analytics.duckdb"


def main():
    if len(sys.argv) < 2:
        print("Usage: python run_sql.py <sql_file> [sql_file2 ...]")
        sys.exit(1)

    con = duckdb.connect(DB_PATH)

    for sql_file in sys.argv[1:]:
        print(f"-- Running: {sql_file}")
        sql = open(sql_file, encoding="utf-8").read()
        for statement in sql.split(";"):
            statement = statement.strip()
            if not statement:
                continue
            result = con.execute(statement)
            if result.description:
                con.sql(statement).show()

    con.close()


if __name__ == "__main__":
    main()
