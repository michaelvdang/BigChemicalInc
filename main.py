from typing import Optional
import sqlite3
from fastapi import FastAPI, Depends
from pydantic import BaseModel
from fastapi.middleware.cors import CORSMiddleware
import contextlib

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

async def get_db():
  with contextlib.closing(sqlite3.connect('var/BigChemicalInc.db', check_same_thread=False)) as db:
    yield db

@app.get("/")
def read_root():
  return {"Hello": "World"}

# get employee info
@app.get("/employees/{employeeID}")
def get_employees(employeeID: int, db: sqlite3.Connection = Depends(get_db)):
  # cur = db.cursor()
  employee = db.execute('SELECT * FROM v_EmployeeInfo WHERE employeeID=?', 
                  [employeeID])
  return {'employee' : employee.fetchone()}

# get employee test results
@app.get("/employees/{employeeID}/drug-test-result/")
def get_employee_drug_test_result(employeeID: int, db: sqlite3.Connection = Depends(get_db)):
  # cur = db.cursor()
  results = db.execute("SELECT * FROM v_DrugTestResults WHERE employeeID=?", 
                  [employeeID])
  return {'test_results' : results.fetchall()}

# get sensor info
@app.get("/sensors/{sensorID}")
def get_sensor_info(sensorID: int, db: sqlite3.Connection = Depends(get_db)):
  # cur = db.cursor()

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
  
  
  
  
  
  
  
  
  
  
  
