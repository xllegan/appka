from sqlalchemy import select
from sqlalchemy.exc import IntegrityError

from .database import AsyncSession
from .models import User
from .schemas import UserCreate
from .utils import hash_password
from .exceptions import UserAlreadyExists, UserNotFound


async def get_user_by_login(session: AsyncSession, login: str) -> User | None:
    result = await session.execute(select(User).where(User.login == login))
    return result.scalar_one_or_none()

async def create_user(session: AsyncSession, user_data: UserCreate) -> User:
    hashed_password_ = hash_password(user_data.password)
    user = User(login=user_data.login, hashed_password=hashed_password_)

    session.add(user)
    try:
        await session.commit()
        await session.refresh(user)
        return user
    except IntegrityError:
        await session.rollback()
        raise UserAlreadyExists("User with this login already exists")

async def update_refresh_token(session: AsyncSession, user_id: int, refresh_token_: str | None):
    result = await session.execute(select(User).where(User.id == user_id))
    user = result.scalar_one_or_none()

    if not user:
        raise UserNotFound(f"User with id {user_id} not found")

    user.refresh_token = refresh_token_
    await session.commit()
    await session.refresh(user)
    return user
