import os
from fastapi import FastAPI, HTTPException
from pydantic import BaseModel, Field
from mistralai import Mistral
from dotenv import load_dotenv
from typing import Optional, Dict

app = FastAPI(title="AI Service")
load_dotenv()

PROMPT_PATH = os.path.join(os.path.dirname(__file__), "prompt.txt")
with open(PROMPT_PATH, "r", encoding="utf-8") as f:
    PROMPT = f.read()

MISTRAL_API_KEY = os.getenv("MISTRAL_API_KEY")
if not MISTRAL_API_KEY:
    raise RuntimeError("MISTRAL_API_KEY not found in environment variables")

client = Mistral(api_key=MISTRAL_API_KEY)

class AIRequest(BaseModel):
    message: str = Field(..., description="Сообщение пользователя")
    model: str = Field(default="devstral-medium-latest", description="Модель Mistral AI")
    temperature: float = Field(default=0.6, ge=0.0, le=2.0, description="Температура генерации")
    max_tokens: Optional[int] = Field(default=400, ge=1, le=8192, description="Максимальное количество токенов")
    top_p: Optional[float] = Field(default=0.6, ge=0.0, le=1.0, description="Top-p параметр")
    random_seed: Optional[int] = Field(default=None, description="Случайное зерно для воспроизводимости")
    safe_mode: bool = Field(default=False, description="Безопасный режим")
    system_prompt: Optional[str] = Field(default=PROMPT, description="Системный промпт")
    response_format: Optional[Dict[str, str]] = Field(default=None, description="Формат ответа")
    stream: bool = Field(default=False, description="Потоковая передача")

class AIResponse(BaseModel):
    response: str
    model: str
    usage: Optional[dict] = None

@app.post("/chat", response_model=AIResponse)
async def chat_with_ai(request: AIRequest):
    try:
        messages = []
        if request.system_prompt:
            messages.append({"role": "system", "content": request.system_prompt})
        messages.append({"role": "user", "content": request.message})

        chat_params = {
            "model": request.model,
            "messages": messages,
            "temperature": request.temperature,
        }
        if request.max_tokens is not None:
            chat_params["max_tokens"] = request.max_tokens
        if request.top_p is not None:
            chat_params["top_p"] = request.top_p
        if request.random_seed is not None:
            chat_params["random_seed"] = request.random_seed
        if request.safe_mode:
            chat_params["safe_mode"] = request.safe_mode
        if request.response_format:
            chat_params["response_format"] = request.response_format
        if request.stream:
            chat_params["stream"] = request.stream

        response = client.chat.complete(**chat_params)
        result = AIResponse(
            response=response.choices[0].message.content,
            model=request.model
        )
        if hasattr(response, 'usage') and response.usage:
            result.usage = {
                "prompt_tokens": response.usage.prompt_tokens,
                "completion_tokens": response.usage.completion_tokens,
                "total_tokens": response.usage.total_tokens
            }
        return result
    except Exception as e:
        raise HTTPException(status_code=500, detail=f"Ошибка AI API: {str(e)}")

@app.get("/models")
async def get_available_models():
    try:
        models = client.models.list()
        return {"models": [model.id for model in models.data]}
    except Exception as e:
        raise HTTPException(status_code=500, detail=f"Ошибка получения моделей: {str(e)}")

if __name__ == "__main__":
    import uvicorn
    uvicorn.run("ai:app", host="0.0.0.0", port=8001, reload=True) 
    