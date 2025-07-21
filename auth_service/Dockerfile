FROM python:3.11-slim

WORKDIR /app

RUN apt-get update && apt-get install -y postgresql-client && rm -rf /var/lib/apt/lists/*

COPY requirements.txt .

RUN pip install --no-cache-dir -r requirements.txt

RUN mkdir auth_service

COPY . /app/auth_service/

RUN echo '#!/bin/sh\n\
while ! pg_isready -h db -p 5432 -U user -d appka; do\n\
  echo "Waiting for database..."\n\
  sleep 2\n\
done\n\
\n\
echo "Database is ready!"\n\
exec "$@"' > /app/entrypoint.sh \
&& chmod +x /app/entrypoint.sh

ENV PYTHONPATH=/app

EXPOSE 8000

ENTRYPOINT ["/app/entrypoint.sh"]

CMD ["uvicorn", "auth_service.main:app", "--host", "0.0.0.0", "--port", "8000"] 