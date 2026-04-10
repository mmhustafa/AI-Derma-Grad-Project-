from fastapi import FastAPI, HTTPException
from pydantic import BaseModel
from typing import List
import expert_logic 

app = FastAPI()

class DiagnosisRequest(BaseModel):
    facts: List[str] # لستة الأكواد اللي الموبايل مجمعها

@app.post("/kb/next-step")
async def next_step(request: DiagnosisRequest):
    # استدعاء المنطق البرمجي
    result = expert_logic.get_next_step(request.facts)
    
    if result["type"] == "error":
        raise HTTPException(status_code=400, detail=result["message"])
        
    return result
