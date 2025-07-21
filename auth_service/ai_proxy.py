import httpx
from fastapi import APIRouter, HTTPException, Depends, status
from pydantic import BaseModel, Field
from typing import Optional, Dict
from .dependencies import get_current_user
from .models import User
from fastapi import Request

router = APIRouter(tags=["AI Proxy"])

AI_SERVICE_URL = "http://localhost:8001"

class AIRequest(BaseModel):
    message: str = Field(..., description="Сообщение пользователя")
    model: str = Field(default="devstral-medium-latest", description="Модель Mistral AI")
    temperature: float = Field(default=0.6, ge=0.0, le=2.0, description="Температура генерации")
    max_tokens: Optional[int] = Field(default=400, ge=1, le=8192, description="Максимальное количество токенов")
    top_p: Optional[float] = Field(default=0.6, ge=0.0, le=1.0, description="Top-p параметр")
    random_seed: Optional[int] = Field(default=None, description="Случайное зерно для воспроизводимости")
    safe_mode: bool = Field(default=False, description="Безопасный режим")
    system_prompt: Optional[str] = Field(default=None, description="Системный промпт")
    response_format: Optional[Dict[str, str]] = Field(default=None, description="Формат ответа")
    stream: bool = Field(default=False, description="Потоковая передача")

@router.post("/ai/chat")
async def proxy_chat(
    ai_request: AIRequest,
    current_user: User = Depends(get_current_user)
):
    try:
        async with httpx.AsyncClient() as client:
            resp = await client.post(f"{AI_SERVICE_URL}/chat", json=ai_request.dict())
        return resp.json()
    except Exception as e:
        raise HTTPException(status_code=500, detail=f"AI proxy error: {str(e)}")

@router.get("/ai/models")
async def proxy_models(current_user: User = Depends(get_current_user)):
    try:
        async with httpx.AsyncClient() as client:
            resp = await client.get(f"{AI_SERVICE_URL}/models")
        return resp.json()
    except Exception as e:
        raise HTTPException(status_code=500, detail=f"AI proxy error: {str(e)}")  
        