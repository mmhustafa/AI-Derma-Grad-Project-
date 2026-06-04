from fastapi import FastAPI, HTTPException
from pydantic import BaseModel
from typing import List
import expert_logic 
import uvicorn 

app = FastAPI()

class DiagnosisRequest(BaseModel):
    facts: List[str] 

@app.post("/kb/next-step")
async def next_step(request: DiagnosisRequest):
    
    result = expert_logic.get_next_step(request.facts)
    
    if result["type"] == "error":
        raise HTTPException(status_code=400, detail=result["message"])
        
    return result


if __name__ == "__main__":
    uvicorn.run(
        app,
        host="0.0.0.0",
        port=8002,
        log_level="info"
    )
