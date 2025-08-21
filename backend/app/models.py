from sqlalchemy.orm import Mapped, mapped_column
from sqlalchemy import text
from .db import Base

class Item(Base):
    __tablename__ = "items"
    id: Mapped[int] = mapped_column(primary_key=True, autoincrement=True)
    name: Mapped[str] = mapped_column()

CREATE_TABLE_SQL = text("""
CREATE TABLE IF NOT EXISTS items (
  id BIGSERIAL PRIMARY KEY,
  name TEXT NOT NULL
);
""")
