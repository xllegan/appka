from fastapi import APIRouter, status, HTTPException
from fastapi.params import Depends
from fastapi.security import OAuth2PasswordRequestForm
from sqlalchemy.ext.asyncio import AsyncSession

from backend.crud import create_user, get_user_by_login, update_refresh_token
from backend.database import get_db
from backend.dependencies import get_current_user
from backend.exceptions import UserAlreadyExists
from backend.schemas import UserResponse, UserCreate, TokenPair, RefreshToken
from backend.utils import verify_password, create_access_token, create_refresh_token, decode_refresh_token
from backend.models import User

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

@router.post("/refresh", response_model=TokenPair)
async def refresh_tokens(
        refresh_data: RefreshToken,
        db: AsyncSession = Depends(get_db)
):
    try:
        payload = decode_refresh_token(refresh_data.refresh_token)
        user_login = payload.get("sub")
        if not user_login:
            raise HTTPException(
                status_code=status.HTTP_401_UNAUTHORIZED,
                detail="Invalid refresh token"
            )
    except Exception as e:
        raise HTTPException(
            status_code=status.HTTP_401_UNAUTHORIZED,
            detail=str(e)
        )

    user = await get_user_by_login(db, user_login)
    if not user or user.refresh_token != refresh_data.refresh_token:
        raise HTTPException(
            status_code=status.HTTP_401_UNAUTHORIZED,
            detail="Invalid refresh token"
        )

    new_access_token = create_access_token(data={"sub": user.login})
    new_refresh_token = create_refresh_token(data={"sub": user.login})

    await update_refresh_token(db, user.id, new_refresh_token)

    return TokenPair(
        access_token=new_access_token,
        refresh_token=new_refresh_token,
        token_type="bearer"
    )

@router.post("/logout")
async def logout_user(
    current_user: User = Depends(get_current_user),
    db: AsyncSession = Depends(get_db)
):
    await update_refresh_token(db, current_user.id, None)
    return {"message": "Successfully logged out"}

@router.get("/me", response_model=UserResponse)
async def get_current_user_info(
    current_user: User = Depends(get_current_user)
):
    return UserResponse(id=current_user.id, login=current_user.login)
