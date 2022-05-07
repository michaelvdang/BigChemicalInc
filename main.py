from typing import Optional
import sqlite3
from fastapi import FastAPI, Depends
from pydantic import BaseModel
from fastapi.middleware.cors import CORSMiddleware
import contextlib
import json

app = FastAPI()

origins = [
    "http://localhost:4200",
    # "http://localhost:*",
    # "http://127.0.0.1:4200"
]

app.add_middleware(
    CORSMiddleware,
    allow_origins=origins,
    # allow_credentials=True,
    allow_methods=["PATCH"], # does this work ?
    # allow_headers=["*"],
)

class TestResult(BaseModel):
  employeeID: int
  date: str
  lab_used: str
  test_used: str
  labTestID: int
  results: bool
  comments: str
  # def __init__(self, result: list):
  #   self.employeeID = result[0]
  #   self.date = result[1]
  #   self.lab_used = result[2]
  #   self.test_used = result[3]
  #   self.labTestID = result[4]
  #   self.results = result[5]
  #   self.comments = result[6]

async def get_db():
  with contextlib.closing(sqlite3.connect('var/BigChemicalInc.db', check_same_thread=False)) as db:
    db.row_factory = sqlite3.Row
    yield db

@app.get("/")
def read_root():
  return {"Hello": "World"}

# get employee info
# requires sqlite3.Row
@app.get("/employees/{employeeID}")
def get_employees(employeeID: int, db: sqlite3.Connection = Depends(get_db)):
  # cur = db.cursor()
  rows = db.execute('SELECT * FROM v_EmployeeInfo WHERE employeeID=?', 
                  [employeeID]).fetchall()
  results = []
  for row in rows:
    results.append(dict(zip(row.keys(), row)))
  return results

# get employee test results
# must create TestResult class
@app.get("/employees/{employeeID}/drug-test-result/")
def get_employee_drug_test_result(employeeID: int, db: sqlite3.Connection = Depends(get_db)):
  # cur = db.cursor()
  rows = db.execute("SELECT * FROM v_DrugTestResult WHERE employeeID=?", 
                  [employeeID]).fetchall()
  results = []
  for row in rows:
    # uses BaseModel
    results.append(TestResult(
        employeeID=row[0], 
        date=row[1], 
        lab_used=row[2], 
        test_used=row[3], 
        abTestID=row[4], 
        results=row[5], 
        comments=row[6]))
    # results.append(TestResult(row))
    # results.append(dict(zip(row.keys(), row)))
  return results

# get sensor info
@app.get("/sensors/{sensorID}")
def get_sensor_info(sensorID: int, db: sqlite3.Connection = Depends(get_db)):
  # cur = db.cursor()
  cur = db.cursor()
  sensor = db.execute("SELECT * FROM v_SensorInfo WHERE sensorID=?",
                        [sensorID])
                
  return {'sensor' : sensor.fetchone()}
  
# get repaired sensor info
@app.get("/repaired-sensors/{sensorID}")
def get_repaired_sensor_info(sensorID: int, db: sqlite3.Connection = Depends(get_db)):
  sensors = db.execute("SELECT * FROM v_RepairedSensor WHERE sensorID=?",
                          [sensorID])
  return {'sensors' : sensors.fetchall()}
  
# get employee accesses
@app.get("/employee-accesses/{employeeID}")#?startDate={startDate}&endDate={endDate}")
def get_employee_accesses(employeeID: int, 
                          startDate: str,
                          endDate: str,
                          db: sqlite3.Connection = Depends(get_db)):
  accesses = db.execute("""SELECT * 
                            FROM v_EmployeeAccess 
                            WHERE employeeID=?
                            AND date 
                            BETWEEN ? AND ?""",
                          [employeeID, startDate, endDate])
  return {'accesses' : accesses.fetchall()}
  
# get employee access rights
@app.get("/employee-access-rights/{employeeID}")
def get_employee_access_rights(employeeID: int, db: sqlite3.Connection = Depends(get_db)):
  access_rights = db.execute('''
                              SELECT * 
                              FROM v_EmployeeAccessRights
                              WHERE employeeID=?
                              ''', [employeeID])
  return {'access_rights' : access_rights.fetchall()}
  
  
  
  
  
  
  
  
  
  
  
