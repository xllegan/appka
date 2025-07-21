from passlib.context import CryptContext
from datetime import timedelta, datetime, timezone
from jose import jwt
import os

from .exceptions import SecretKeyNotFound, InvalidSecretKey, InvalidKeyType

ACCESS_TOKEN_EXPIRES_MINUTES = 30
REFRESH_TOKEN_EXPIRES_DAYS = 30
SECRET_KEY_MIN_CHARS = 32
ALGORITHM = "HS256"

pwd_context = CryptContext(
    schemes=["bcrypt"],
    deprecated="auto"
)

def get_secret_key(key_type: str) -> str:
    if key_type == "access":
        secret_key = os.getenv("SECRET_KEY_ACCESS")
    elif key_type == "refresh":
        secret_key = os.getenv("SECRET_KEY_REFRESH")
    else:
        raise InvalidKeyType("Key type can be only 'access' or 'refresh'")

    if not secret_key:
        raise SecretKeyNotFound("You don't have any secret key or it cannot be parsed")
    if len(secret_key) < SECRET_KEY_MIN_CHARS:
        raise InvalidSecretKey(
            f"Secret key must be at least {SECRET_KEY_MIN_CHARS} chars long (now it is {len(secret_key)})"
        )

    return secret_key

def hash_password(pwd: str) -> str:
    return pwd_context.hash(pwd)

def verify_password(pwd: str, hashed: str) -> bool:
    return pwd_context.verify(pwd, hashed)

def create_access_token(data: dict, expires_delta: timedelta = None) -> str:
    to_encode = data.copy()

    if expires_delta:
        expire = datetime.now(timezone.utc) + expires_delta
    else:
        expire = datetime.now(timezone.utc) + timedelta(minutes=ACCESS_TOKEN_EXPIRES_MINUTES)

    to_encode.update({"exp": expire})

    secret_key = get_secret_key("access")

    return jwt.encode(to_encode, secret_key, algorithm=ALGORITHM)

def decode_access_token(access_token: str) -> dict:
    secret_key = get_secret_key("access")

    return jwt.decode(
        access_token,
        secret_key,
        algorithms=[ALGORITHM],
        options={"require_exp": True}
    )

def create_refresh_token(data: dict) -> str:
    to_encode = data.copy()
    expire = datetime.now(timezone.utc) + timedelta(days=REFRESH_TOKEN_EXPIRES_DAYS)
    to_encode.update({"exp": expire})

    secret_key = get_secret_key("refresh")
    return jwt.encode(to_encode, secret_key, algorithm=ALGORITHM)

def decode_refresh_token(refresh_token: str) -> dict:
    secret_key = get_secret_key("refresh")

    return jwt.decode(
        refresh_token,
        secret_key,
        algorithms=[ALGORITHM],
        options={"require_exp": True}
    )
