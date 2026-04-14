import pandas as pd
import sqlite3
import os

# ---------- PATH ----------
BASE_DIR = os.path.dirname(os.path.abspath(__file__))
DATA_PATH = os.path.join(BASE_DIR, "../dataset/medicines.csv")
DB_PATH = os.path.join(BASE_DIR, "medicines.db")

# ---------- LOAD ----------
df = pd.read_csv(DATA_PATH)

# ---------- CLEAN COLUMN NAMES ----------
df.columns = [c.strip().lower() for c in df.columns]

# ---------- RENAME ----------
df = df.rename(columns={
    "manufacturer_name": "manufacturer",
    "price(₹)": "price",
    "is_discontinued": "is_discontinued",
    "pack_size_label": "pack_size"
})

# ---------- CREATE COMPOSITION ----------
df["composition"] = (
    df["short_composition1"].fillna("").astype(str) + " " +
    df["short_composition2"].fillna("").astype(str)
).str.strip()

# ---------- SELECT FINAL COLUMNS ----------
df = df[[
    "id",
    "name",
    "manufacturer",
    "composition",
    "price",
    "is_discontinued",
    "type",
    "pack_size"
]]

# ---------- CLEAN ----------
df["price"] = pd.to_numeric(df["price"], errors="coerce")
df = df.dropna(subset=["name", "manufacturer", "price"])

# ---------- CREATE DB ----------
os.makedirs(os.path.dirname(DB_PATH), exist_ok=True)

conn = sqlite3.connect(DB_PATH)

# Replace table
df.to_sql("medicines", conn, if_exists="replace", index=False)

# ---------- INDEXES (IMPORTANT FOR SPEED) ----------
conn.execute("CREATE INDEX IF NOT EXISTS idx_name ON medicines(name)")
conn.execute("CREATE INDEX IF NOT EXISTS idx_manufacturer ON medicines(manufacturer)")

conn.commit()
conn.close()

print("✅ Database created successfully!")
print(df.head())