from fastapi import FastAPI, Depends, HTTPException
from fastapi.middleware.cors import CORSMiddleware
from pydantic import BaseModel
from sqlalchemy import select, text
from sqlalchemy.orm import Session
from .db import Base, engine, get_session
from .models import Item, CREATE_TABLE_SQL

app = FastAPI()
app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"], allow_credentials=True, allow_methods=["*"], allow_headers=["*"],
)

class ItemIn(BaseModel):  name: str
class ItemOut(BaseModel): id: int; name: str

@app.on_event("startup")
def on_startup():
    with engine.begin() as conn:
        conn.execute(CREATE_TABLE_SQL)
    Base.metadata.create_all(bind=engine)

@app.get("/health")
def health(db: Session = Depends(get_session)):
    try:
        db.execute(text("SELECT 1"))
        return {"status": "ok", "db": "up"}
    except Exception as e:
        raise HTTPException(status_code=500, detail=f"db error: {e}")

@app.get("/api/items", response_model=list[ItemOut])
def list_items(db: Session = Depends(get_session)):
    rows = db.execute(select(Item).order_by(Item.id)).scalars().all()
    return [ItemOut(id=r.id, name=r.name) for r in rows]

@app.post("/api/items", response_model=ItemOut)
def create_item(payload: ItemIn, db: Session = Depends(get_session)):
    row = Item(name=payload.name)
    db.add(row); db.commit(); db.refresh(row)
    return ItemOut(id=row.id, name=row.name)
