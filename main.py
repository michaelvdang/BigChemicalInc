from typing import Optional
import sqlite3
from fastapi import FastAPI, Depends

app = FastAPI()

def get_db():
  with sqlite3.connect('var/BigChemicalInc.db') as db:
    yield db

@app.get("/")
def read_root():
  return {"Hello": "World"}


@app.get("/items/{item_id}")
def get_item(item_id: int, q: Optional[str] = None):
  return {"item_id": item_id, "q": q}


@app.get("/employees/{employeeID}")
def get_employees(employeeID: int, db: sqlite3.Connection = Depends(get_db)):
  
  
  
  return {"employeeID": employeeID}
