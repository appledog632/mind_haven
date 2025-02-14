import sqlalchemy
from sqlalchemy.orm import Mapped, mapped_column
from .base import Base


class User(Base):
    __tablename__ = "users"
    id: Mapped[int] = mapped_column(
        sqlalchemy.Integer, primary_key=True, autoincrement=False, index=True
    )
    email: Mapped[str] = mapped_column(
        sqlalchemy.String
    )
    password: Mapped[str] = mapped_column(
        sqlalchemy.String
    )
