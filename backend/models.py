from sqlalchemy.orm import Mapped, mapped_column
from backend.database import Base

class User(Base):
    __tablename__ = "users"

    id: Mapped[int] = mapped_column(primary_key=True, autoincrement=True)
    login: Mapped[str] = mapped_column(unique=True, nullable=False)
    hashed_password: Mapped[str] = mapped_column(nullable=False)
    refresh_token: Mapped[str | None] = mapped_column(nullable=True)  # Для хранения текущего refresh токена

    def __repr__(self):
        return f"<User(id={self.id}, login={self.login})>"
