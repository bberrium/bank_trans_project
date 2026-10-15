import os

base_dir = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))

customers_path  = os.path.join(base_dir, 'data', 'db', 'raw', 'BankCustomerData.csv')
operations_path = os.path.join(base_dir, 'data', 'db', 'raw', 'BankTransaction.csv')
db_path         = os.path.join(base_dir, 'data', 'db', 'bank.db')
schema_path     = os.path.join(base_dir, 'src', 'schema.sql')