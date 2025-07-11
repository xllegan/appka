import os
from fastapi import APIRouter, Depends, HTTPException
from pydantic import BaseModel
from mistralai import Mistral
from backend.dependencies import get_current_user
from backend.models import User
from backend.exceptions import APIKeyNotFound

router = APIRouter(tags=["AI"])

MISTRAL_API_KEY = os.getenv("MISTRAL_API_KEY")
if not MISTRAL_API_KEY:
    raise APIKeyNotFound("MISTRAL_API_KEY not found in environment variables")

client = Mistral(api_key=MISTRAL_API_KEY)

class AIRequest(BaseModel):
    message: str
    model: str = "mistral-tiny"
    temperature: float = 0.7

class AIResponse(BaseModel):
    response: str
    model: str

@router.post("/chat", response_model=AIResponse)
async def chat_with_ai(
    request: AIRequest,
    current_user: User = Depends(get_current_user)
):
    try:
        messages = [{"role": "user", "content": request.message}]
        response = client.chat(
            model=request.model,
            messages=messages,
            temperature=request.temperature
        )
        return AIResponse(
            response=response.choices[0].message.content,
            model=request.model
        )
    except Exception as e:
        raise HTTPException(status_code=500, detail=str(e))
