import joblib
import pandas as pd
import os

# Load model
MODEL_PATH = os.path.join(os.path.dirname(__file__), "../models/model.pkl")
model = joblib.load(MODEL_PATH)

def predict_medicine(features_dict):

    df = pd.DataFrame([features_dict])

    prediction = model.predict(df)[0]
    confidence = model.predict_proba(df)[0][prediction]

    return {
        "prediction": "Fake" if prediction == 1 else "Genuine",
        "confidence": round(confidence * 100, 2)
    }