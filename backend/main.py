from contextlib import asynccontextmanager

from fastapi import FastAPI
from fastapi.middleware.cors import CORSMiddleware
from backend.database import engine, Base
from backend.auth import router as auth_router

app = FastAPI(
    title="'Appka' API",
    description="This API currently for user authentication and authorization",
    version="1.0.0"
)

app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)

app.include_router(auth_router, prefix="/auth")

@asynccontextmanager
async def init_db():
    async with engine.begin() as conn:
        await conn.run_sync(Base.metadata.create_all)
