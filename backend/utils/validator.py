import sqlite3
import re

from config import DB_PATH
from utils.matcher import find_match
from utils.barcode import scan_barcode
from ml.predict import predict_medicine

# ---------- DB CONNECTION ----------
conn = sqlite3.connect(DB_PATH, check_same_thread=False)
cursor = conn.cursor()

# ---------- EXTRACT BATCH ----------
def extract_batch(text):
    patterns = [
        r"batch\s*no[:\s]*([a-zA-Z0-9]+)",
        r"lot[:\s]*([a-zA-Z0-9]+)"
    ]
    for p in patterns:
        m = re.search(p, text)
        if m:
            return m.group(1)
    return None

# ---------- VALIDATE ----------
def validate(text, image_path=None):

    match, score = find_match(text)
    batch = extract_batch(text)
    barcode = scan_barcode(image_path) if image_path else None

    # ---------- NO MATCH ----------
    if not match:
        return {
            "status": "Suspicious",
            "confidence_rule_based": 30,
            "ml_prediction": "Unknown",
            "ml_confidence": 0
        }

    # ---------- FETCH FROM DB ----------
    cursor.execute(
        "SELECT name, manufacturer, composition, price FROM medicines WHERE LOWER(name)=?",
        (match,)
    )
    row = cursor.fetchone()

    if not row:
        return {
            "status": "Suspicious",
            "confidence_rule_based": 40,
            "ml_prediction": "Unknown",
            "ml_confidence": 0
        }

    name, manufacturer, composition, price = row

    # ---------- RULE-BASED SCORING ----------
    confidence = 50

    # Name similarity score
    if score > 90:
        confidence += 30
    elif score > 75:
        confidence += 20
    elif score > 60:
        confidence += 10
    else:
        confidence -= 15

    # Name appears in text
    if name.lower() in text:
        confidence += 10

    # Composition check
    if composition and composition.lower() in text:
        confidence += 15

    # Barcode presence
    if barcode:
        confidence += 10

    # Batch presence
    if batch:
        confidence += 5

    # ---------- RULE STATUS ----------
    if confidence >= 85:
        status = "Genuine"
    elif confidence >= 60:
        status = "Needs Verification"
    else:
        status = "Suspicious"

    # ---------- ML FEATURES ----------
    features = {
        "name_length": len(name),
        "manufacturer_match": 1 if manufacturer else 0,
        "composition_match": 1 if composition else 0,
        "price": price
    }

    # ---------- ML PREDICTION ----------
    try:
        ml_result = predict_medicine(features)
    except:
        ml_result = {
            "prediction": "Unknown",
            "confidence": 0
        }

    # ---------- FINAL DECISION (COMBINED) ----------
    if ml_result["prediction"] == "Fake" and confidence < 70:
        final_status = "Suspicious"
    else:
        final_status = status

    # ---------- RESPONSE ----------
    return {
        "medicine": name,
        "manufacturer": manufacturer,
        "composition": composition,
        "batch_number": batch,
        "barcode": barcode,

        "rule_status": status,
        "confidence_rule_based": confidence,

        "ml_prediction": ml_result["prediction"],
        "ml_confidence": ml_result["confidence"],

        "final_status": final_status
    }