from pydantic import BaseModel, Field, ConfigDict

class UserBase(BaseModel):
    login: str = Field(
        min_length=3,
        max_length=25,
        examples=["john123"],
        description="Имя пользователя"
    )

    password: str = Field(
        min_length=6,
        max_length=30,
        examples=["g%4l@6A"],
        description="Пароль (длиной от 6 до 30 символов)"
    )

class UserCreate(UserBase):
    pass

class UserLogin(UserBase):
    pass

class UserResponse(BaseModel):
    login: str = Field(description="User's login")
    id: int = Field(description="User's unique id number")
    model_config = ConfigDict(from_attributes=True)

class Token(BaseModel):
    access_token: str = Field(description="JWT token for authorization")
    token_type: str = "bearer"
