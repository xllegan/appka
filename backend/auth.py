from fastapi import APIRouter, status, HTTPException
from fastapi.params import Depends
from fastapi.security import OAuth2PasswordRequestForm
from sqlalchemy.ext.asyncio import AsyncSession

from backend.crud import create_user, get_user_by_login, update_refresh_token
from backend.database import get_db
from backend.exceptions import UserAlreadyExists
from backend.schemas import UserResponse, UserCreate, TokenPair
from backend.utils import verify_password, create_access_token, create_refresh_token

router = APIRouter(tags=["Authentication"])

def incorrect_login_or_pwd():
    raise HTTPException(
        status_code=status.HTTP_401_UNAUTHORIZED,
        detail="Incorrect login or password",
        headers={"WWW-Authenticate": "Bearer"},
    )

@router.post("/register", response_model=UserResponse, status_code=status.HTTP_201_CREATED)
async def register_user(
        user_data: UserCreate,
        db: AsyncSession = Depends(get_db)
):
    try:
        new_user = await create_user(db, user_data)
        return UserResponse(id=new_user.id, login=new_user.login)
    except UserAlreadyExists as e:
        raise HTTPException(
            status_code=status.HTTP_400_BAD_REQUEST,
            detail=str(e)
        )

@router.post("/login", response_model=TokenPair)
async def login_user(
        form_data: OAuth2PasswordRequestForm = Depends(),
        db: AsyncSession = Depends(get_db)
):
    user = await get_user_by_login(db, form_data.username)
    if not user:
        incorrect_login_or_pwd()

    if not verify_password(form_data.password, str(user.hashed_password)):
        incorrect_login_or_pwd()

    access_token_ = create_access_token(data={"sub": user.login})
    refresh_token_ = create_refresh_token(data={"sub": user.login})

    await update_refresh_token(db, user.id, refresh_token_)

    return TokenPair(
        access_token=access_token_,
        refresh_token=refresh_token_,
        token_type="bearer"
    )
