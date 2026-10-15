import os
import sqlite3
import pandas as pd
import config

customers  = pd.read_csv(config.customers_path,  on_bad_lines='skip')
operations = pd.read_csv(config.operations_path)

customers  = customers.drop_duplicates(subset=['id']).reset_index(drop=True)
operations = operations.drop_duplicates(subset=['id']).reset_index(drop=True)

os.makedirs(os.path.dirname(config.db_path), exist_ok=True)
conn = sqlite3.connect(config.db_path)

try:
    with open(config.schema_path) as f:
        conn.executescript(f.read())

    customers.to_sql('customers',  conn, if_exists='append', index=False)
    operations.to_sql('operations', conn, if_exists='append', index=False)
    conn.commit()
    print(f"[OK] {len(customers)} customers, {len(operations)} operations -> {config.db_path}")
finally:
    conn.close()