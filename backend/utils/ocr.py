import easyocr

reader = easyocr.Reader(['en'])

def extract_text(image_path):
    try:
        results = reader.readtext(image_path)
        return " ".join([r[1] for r in results]).lower()
    except:
        return ""