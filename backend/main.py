from fastapi import FastAPI, UploadFile, File, Form
from fastapi.middleware.cors import CORSMiddleware
import shutil, os
from config import TEMP_DIR
from utils.ocr import extract_text
from utils.validator import validate

app = FastAPI(title="Fake Medicine Detection API 🚀")

# ✅ Add this CORS middleware
app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)

os.makedirs(TEMP_DIR, exist_ok=True)

@app.get("/")
def home():
    return {"message": "Backend running ✅"}

@app.post("/verify-text")
def verify_text(text: str = Form(...)):
    result = validate(text)
    return {"input_text": text, "result": result}

@app.post("/upload-image")
async def upload_image(file: UploadFile = File(...)):
    try:
        path = os.path.join(TEMP_DIR, file.filename)
        with open(path, "wb") as buffer:
            shutil.copyfileobj(file.file, buffer)
        text = extract_text(path)
        result = validate(text, path)
        return {"extracted_text": text, "result": result}
    except Exception as e:
        return {"error": str(e)}