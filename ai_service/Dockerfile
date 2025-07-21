FROM python:3.11-slim

WORKDIR /app

COPY requirements.txt .

RUN pip install --no-cache-dir -r requirements.txt

RUN mkdir ai_service

COPY . /app/ai_service/

ENV PYTHONPATH=/app

EXPOSE 8001

CMD ["uvicorn", "ai_service.ai:app", "--host", "0.0.0.0", "--port", "8001"] 