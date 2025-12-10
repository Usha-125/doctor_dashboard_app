# ml_api/app.py
from fastapi import FastAPI, HTTPException, Request
from fastapi.exceptions import RequestValidationError
from fastapi.responses import JSONResponse
from pydantic import BaseModel
from typing import Dict, Any
import joblib
import numpy as np
from google.cloud import firestore
import os
import logging

# -------- logger ----------
logging.basicConfig(level=logging.INFO)
logger = logging.getLogger("ml_api")

# -------- FastAPI app ----------
app = FastAPI(title="Patient Recovery Predictor")

# -------- Load model ----------
MODEL_PATH = os.environ.get("MODEL_PATH", "model.pkl")
try:
    model = joblib.load(MODEL_PATH)
    logger.info("Model loaded successfully from %s", MODEL_PATH)
except Exception as e:
    logger.exception("Failed to load model")
    # Raising here stops the app startup so you'll see the error immediately
    raise RuntimeError(f"Error loading model.pkl: {e}")

# -------- Firestore client ----------
# Locally this uses GOOGLE_APPLICATION_CREDENTIALS env var; in Cloud Run it uses default credentials
db = firestore.Client()

# -------- Pydantic request schema ----------
class PredictRequest(BaseModel):
    patientId: str
    features: Dict[str, Any]

# -------- Validation error handler (gives clearer 422 responses) ----------
@app.exception_handler(RequestValidationError)
async def validation_exception_handler(request: Request, exc: RequestValidationError):
    try:
        body = await request.json()
    except Exception:
        body = "<not-json or empty>"
    logger.error("Validation error for request body: %s", body)
    logger.error("Validation error details: %s", exc.errors())
    return JSONResponse(
        status_code=422,
        content={
            "message": "Request validation failed",
            "errors": exc.errors(),
            "body": body
        },
    )

# -------- Prediction endpoint ----------
@app.post("/predict")
def predict(req: PredictRequest):
    logger.info("Received predict request for patientId=%s features=%s", req.patientId, req.features)

    # Ensure consistent feature order used at training time
    feature_order = ["Max_Angle", "Min_Resistance"]

    # Validate presence of features and convert to float safely
    try:
        values = []
        for f in feature_order:
            if f not in req.features:
                raise KeyError(f)
            # attempt numeric conversion
            try:
                val = float(req.features[f])
            except Exception as e:
                raise ValueError(f"Feature '{f}' must be numeric. Failed to convert value '{req.features[f]}': {e}")
            values.append(val)
        X = np.array([values])
    except KeyError as e:
        missing_field = e.args[0] if e.args else str(e)
        logger.warning("Missing feature: %s", missing_field)
        raise HTTPException(status_code=400, detail=f"Missing feature: {missing_field}")
    except ValueError as e:
        logger.warning("Invalid feature value: %s", e)
        raise HTTPException(status_code=400, detail=str(e))
    except Exception as e:
        logger.exception("Unexpected error while parsing features")
        raise HTTPException(status_code=400, detail=f"Invalid features: {e}")

    # Run prediction
    try:
        pred = model.predict(X)[0]
    except Exception as e:
        logger.exception("Prediction failed")
        raise HTTPException(status_code=500, detail=f"Prediction failed: {e}")

    status_label = str(pred)
    logger.info("Predicted status for %s => %s", req.patientId, status_label)

    # Write prediction back to Firestore (merge)
    try:
        doc_ref = db.collection("patients").document(req.patientId)
        doc_ref.set({
            "Recovery_Status": status_label,
            "statusUpdatedAt": firestore.SERVER_TIMESTAMP
        }, merge=True)
    except Exception as e:
        logger.exception("Failed to write to Firestore")
        raise HTTPException(status_code=500, detail=f"Firestore write error: {e}")

    return {"patientId": req.patientId, "Recovery_Status": status_label}
