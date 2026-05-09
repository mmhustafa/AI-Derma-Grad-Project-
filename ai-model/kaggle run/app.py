import io
import numpy as np
from contextlib import asynccontextmanager

from fastapi import FastAPI, File, UploadFile, HTTPException
from fastapi.responses import JSONResponse
import tensorflow as tf
from tensorflow.keras.applications.efficientnet import preprocess_input as efficientnet_preprocess
from PIL import Image

MODEL_PATH  = "derma_model.keras"
IMG_SIZE    = (224, 224)
CLASS_NAMES = [
    "Acne",
    "Basal Cell Carcinoma",
    "Benign Keratosis-like Lesions",
    "Eczema",                          # merged: Atopic Dermatitis + Eczema
    "Melanocytic Nevi",
    "Melanoma",
    "Psoriasis",
    "Seborrheic Keratoses",
    "Tinea Ringworm Candidiasis",
    "Warts Molluscum",
]  # 10 classes (Atopic Dermatitis merged into Eczema)

model = None

@asynccontextmanager
async def lifespan(app: FastAPI):
    global model
    model = tf.keras.models.load_model(MODEL_PATH)
    print(f"Model loaded from {MODEL_PATH}")
    yield

app = FastAPI(
    title       = "Dermatology AI API",
    description = "EfficientNetB0-based skin disease classifier",
    version     = "2.0.0",
    lifespan    = lifespan,
)


def preprocess(image_bytes: bytes) -> np.ndarray:
    img = Image.open(io.BytesIO(image_bytes)).convert("RGB")
    img = img.resize(IMG_SIZE)
    arr = np.array(img, dtype=np.float32)
    arr = efficientnet_preprocess(arr)
    return np.expand_dims(arr, axis=0)


@app.post("/predict")
async def predict(file: UploadFile = File(...)):
    if not file.content_type.startswith("image/"):
        raise HTTPException(status_code=400, detail="File must be an image.")
    image_bytes = await file.read()
    try:
        batch = preprocess(image_bytes)
        probs = model.predict(batch, verbose=0)[0]
    except Exception as e:
        raise HTTPException(status_code=500, detail=f"Prediction error: {e}")

    pred_idx   = int(np.argmax(probs))
    confidence = float(probs[pred_idx])
    top3 = [
        {"disease": CLASS_NAMES[i], "confidence": round(float(probs[i]), 4)}
        for i in np.argsort(probs)[::-1][:3]
    ]
    return JSONResponse({
        "disease"    : CLASS_NAMES[pred_idx],
        "confidence" : round(confidence, 4),
        "top_3"      : top3,
    })


@app.get("/health")
def health():
    return {"status": "ok", "model_loaded": model is not None}