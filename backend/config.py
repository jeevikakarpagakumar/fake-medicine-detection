import os

BASE_DIR = os.path.dirname(os.path.abspath(__file__))

DB_PATH = os.path.join(BASE_DIR, "database", "medicines.db")
MODEL_PATH = os.path.join(BASE_DIR, "models", "model.pkl")
TEMP_DIR = os.path.join(BASE_DIR, "temp")