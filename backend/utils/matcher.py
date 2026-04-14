from fuzzywuzzy import process
import sqlite3
from config import DB_PATH

conn = sqlite3.connect(DB_PATH, check_same_thread=False)
cursor = conn.cursor()

cursor.execute("SELECT name FROM medicines")
names = [row[0].lower() for row in cursor.fetchall()]

def find_match(text):
    if not text:
        return None, 0
    return process.extractOne(text, names)