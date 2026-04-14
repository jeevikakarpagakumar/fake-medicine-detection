import pandas as pd
import random
from sklearn.model_selection import train_test_split

# ---------- LOAD DATA ----------
df = pd.read_csv("../dataset/medicines.csv")

# ---------- CLEAN COLUMN NAMES ----------
df.columns = [c.strip().lower() for c in df.columns]

# ---------- RENAME ----------
df = df.rename(columns={
    "manufacturer_name": "manufacturer",
    "price(₹)": "price"
})

# ---------- CREATE COMPOSITION ----------
df["composition"] = (
    df["short_composition1"].fillna("").astype(str) + " " +
    df["short_composition2"].fillna("").astype(str)
).str.strip()

# ---------- SELECT ----------
df = df[["name", "manufacturer", "composition", "price"]]

# ---------- CLEAN ----------
df = df.dropna(subset=["name", "manufacturer", "composition", "price"])
df["price"] = pd.to_numeric(df["price"], errors="coerce")
df = df.dropna(subset=["price"])

# ---------- LABEL ----------
df["label"] = 0

# ---------- FAKE GENERATION ----------
fake_rows = []

def corrupt_text(text):
    if not isinstance(text, str):
        return text
    return text.replace("a", "e").replace("i", "1")

def generate_fake(row):
    fake = row.copy()

    if random.random() < 0.5:
        fake["name"] = corrupt_text(fake["name"])

    if random.random() < 0.5:
        fake["manufacturer"] = random.choice([
            "Fake Pharma Ltd", "XYZ Labs", "Unknown Pharma"
        ])

    if random.random() < 0.5:
        fake["composition"] = random.choice([
            "Paracetamol", "Ibuprofen", "Unknown Compound"
        ])

    if random.random() < 0.5:
        fake["price"] = fake["price"] * random.uniform(0.1, 0.6)

    fake["label"] = 1
    return fake

# Generate fake data
for _, row in df.iterrows():
    for _ in range(2):
        fake_rows.append(generate_fake(row))

fake_df = pd.DataFrame(fake_rows)

# ---------- COMBINE ----------
final_df = pd.concat([df, fake_df], ignore_index=True)

# Shuffle
final_df = final_df.sample(frac=1).reset_index(drop=True)

# ---------- TRAIN-TEST SPLIT ----------
train_df, test_df = train_test_split(
    final_df,
    test_size=0.2,   # 80% train, 20% test
    random_state=42,
    stratify=final_df["label"]  # keeps balance
)

# ---------- SAVE ----------
train_df.to_csv("../dataset/training_data.csv", index=False)
test_df.to_csv("../dataset/test_data.csv", index=False)

print("✅ Training + Test datasets created!")
print(f"Train size: {len(train_df)}")
print(f"Test size: {len(test_df)}")