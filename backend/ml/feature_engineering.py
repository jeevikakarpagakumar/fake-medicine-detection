import pandas as pd

# ---------- LOAD ----------
train_df = pd.read_csv("../dataset/training_data.csv")
test_df = pd.read_csv("../dataset/test_data.csv")
ref_df = pd.read_csv("../dataset/medicines.csv")

# ---------- CLEAN ----------
ref_df.columns = [c.strip().lower() for c in ref_df.columns]

ref_df = ref_df.rename(columns={
    "manufacturer_name": "manufacturer",
    "price(₹)": "price"
})

# Create composition
ref_df["composition"] = (
    ref_df["short_composition1"].fillna("").astype(str) + " " +
    ref_df["short_composition2"].fillna("").astype(str)
).str.strip()

manufacturer_set = set(ref_df["manufacturer"])
composition_set = set(ref_df["composition"])

# ---------- FEATURE FUNCTION ----------
def create_features(df):

    feature_df = pd.DataFrame()

    feature_df["name_length"] = df["name"].astype(str).apply(len)

    feature_df["manufacturer_match"] = df["manufacturer"].apply(
        lambda x: 1 if x in manufacturer_set else 0
    )

    feature_df["composition_match"] = df["composition"].apply(
        lambda x: 1 if x in composition_set else 0
    )

    feature_df["price"] = df["price"]

    feature_df["label"] = df["label"]

    return feature_df

# ---------- APPLY ----------
train_features = create_features(train_df)
test_features = create_features(test_df)

# ---------- SAVE ----------
train_features.to_csv("../dataset/train_features.csv", index=False)
test_features.to_csv("../dataset/test_features.csv", index=False)

print("✅ FAST features created!")