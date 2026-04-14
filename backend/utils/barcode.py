import cv2

try:
    from pyzbar.pyzbar import decode
except:
    decode = None

def scan_barcode(image_path):
    if not decode:
        return None

    try:
        img = cv2.imread(image_path)
        barcodes = decode(img)

        for b in barcodes:
            return b.data.decode("utf-8")

    except:
        return None

    return None