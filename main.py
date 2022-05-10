from audioop import add
from typing import Optional, List
import sqlite3
from fastapi import Body, FastAPI, Depends, Response
from pydantic import BaseModel
from fastapi.middleware.cors import CORSMiddleware
import contextlib
import json
from models.my_models import Degree, Education, Employee, Address, RepairedSensor, Sensor, DrugTest

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
def get_employee_info(employeeID: int,
                      db: sqlite3.Connection = Depends(get_db)):
  employee_info = db.execute('SELECT * FROM v_EmployeeInfo WHERE employeeID=?', 
                                [employeeID]).fetchone()
  employee_education = db.execute('SELECT * FROM Education WHERE employeeID=?', 
                                [employeeID]).fetchall()
  return {'employee_info': employee_info, 'employee_education': employee_education}
  row = db.execute('SELECT * FROM v_EmployeeInfo WHERE employeeID=?', 
                  [employeeID]).fetchone()
  e = Employee(
      employeeID=row['employeeID'],
      name=row['name'],
      taxpayer_id=row['taxpayer_id'],
      date_hired=row['date_hired'],
      department=row['department'],
      address=row['address'],
      city=row['city'],
      state=row['state'],
      zip=row['zip'],
      phone=row['phone'],
      supervisor=row['supervisor']
  )
  education = db.execute('SELECT * FROM EmployeeEducation WHERE employeeID=?',
                    [employeeID]).fetchall()
  degrees = []
  for rowww in education:
    # TODO: what does '*' do in Degree() hint?
    degree = Degree(
      school_name=rowww['school_name'],
      startDate=rowww['startDate'],
      endDate=rowww['endDate'],
      degree=rowww['degree'],
      GPA=rowww['GPA']
    )
    degrees.append(degree)
  e.education = degrees
  result = {"employee_info": row, "education": education}
  return result
  return e

@app.put("/employees/{employeeID}")
def update_employee_info(employeeID: int,
                          employee: Employee,
                          address: Address,
                          education: Education,
                          db: sqlite3.Connection = Depends(get_db)):
  try:
    db.execute('''
        UPDATE Employee
        SET supervisorID=?,
            name=?, title=?, department=?, taxpayer_id=?, securityClearance=?,
            date_hired=?, phone=?, dob=?
        WHERE employeeID=?
        ''',
        [
          employee.supervisorID,
          employee.name,
          employee.title,
          employee.department,
          employee.taxpayer_id,
          employee.securityClearance,
          employee.date_hired,
          employee.phone,
          employee.dob,
          employeeID, 
        ])
    db.execute('''
        UPDATE Address
        SET address=?, city=?, state=?, zip=?
        WHERE employeeID=?
        ''',
        [
          address.address,
          address.city,
          address.state,
          address.zip,
          employeeID
        ])
    for degree in education.degrees:
      db.execute('DELETE FROM Education WHERE employeeID=?', [employeeID])
      db.execute('''
          INSERT INTO Education
          (employeeID, degree_name, school_name, startDate, endDate, GPA)
          VALUES (?,?,?,?,?,?) 
          ''',
          [
            employeeID,
            degree.degree_name,
            degree.school_name,
            degree.startDate,
            degree.endDate,
            degree.GPA,
          ])
    db.commit()
  except sqlite3.IntegrityError:
      return "ERROR: sqlite3.IntegrityError"
  return Response(None, status_code=204)


@app.post("/employees/{employeeID}")
def add_employee_info(employee: Employee,
                 address: Address,
                 education: Education,
                 db: sqlite3.Connection = Depends(get_db)):
  try:
    db.execute('''
        INSERT INTO Employee(employeeID, supervisorID,
                    name, title, department, taxpayer_id, securityClearance,
                    date_hired, phone, dob) 
        VALUES (?,?,?,?,?,?,?,?,?,?)
        ''',
        [
          employee.employeeID,
          employee.supervisorID,
          employee.name,
          employee.title,
          employee.department,
          employee.taxpayer_id,
          employee.securityClearance,
          employee.date_hired,
          employee.phone,
          employee.dob
        ])
    db.execute('''
        INSERT INTO Address
        VALUES (?,?,?,?,?)
        ''', 
        [
          employee.employeeID,
          address.address,
          address.city,
          address.state,
          address.zip
        ])
    for d in education.degrees:
      db.execute('''
          INSERT INTO Education
          VALUES (?,?,?,?,?,?)
          ''',
          [
            employee.employeeID,
            d.degree_name,
            d.school_name,
            d.startDate,
            d.endDate,
            d.GPA
          ])
    db.commit()
  except sqlite3.IntegrityError:
    return "ERROR: this employeeID already exists"
  return Response(None, status_code=201)

# get employee test results
# must create TestResult class
@app.get("/employees/{employeeID}/drug-test-results/")
def get_employee_drug_test_result(employeeID: int, db: sqlite3.Connection = Depends(get_db)):
  rows = db.execute("SELECT * FROM v_DrugTestResult WHERE employeeID=?", 
                  [employeeID]).fetchall()
  return {'drug_test_results' : rows}


@app.put("/employees/{employeeID}/drug-test-results/{labTestID}")
def update_employee_drug_test_result(employeeID: int,
                                      labTestID: int,
                                      drugtest: DrugTest, 
                                      db: sqlite3.Connection = Depends(get_db)):
  try:
    db.execute('''
        UPDATE DrugTest
        SET date=?, lab_used=?, test_used=?, results=?, comments=?
        WHERE employeeID=? AND labTestID=?
        ''',
        [
          drugtest.date,
          drugtest.lab_used,
          drugtest.test_used,
          drugtest.results,
          drugtest.comments,
          employeeID,
          labTestID
        ])
    db.commit()
  except sqlite3.IntegrityError:
    return "ERROR: SQLite Integrity Error"
  return Response(None, status_code=204)

@app.post("/employees/{employeeID}/drug-test-results/")
def add_employee_drug_test_result(employeeID: int,
                                  drugtest: DrugTest, 
                                  db: sqlite3.Connection = Depends(get_db)):
  try:
    db.execute('INSERT INTO DrugTest VALUES (?,?,?,?,?,?,?)',
        [
          drugtest.employeeID,
          drugtest.labTestID,
          drugtest.date,
          drugtest.lab_used,
          drugtest.test_used,
          drugtest.results,
          drugtest.comments
        ])
    db.commit()
  except sqlite3.IntegrityError:
    return "ERROR: SQLite Integrity Error"
  return Response(None, status_code=201)


# get sensor info
@app.get("/sensors/{sensorID}")
def get_sensor_info(sensorID: int, db: sqlite3.Connection = Depends(get_db)):
  row = db.execute("SELECT * FROM v_SensorInfo WHERE sensorID=?",
                        [sensorID]).fetchone()
  return {'sensors' : row}

@app.put("/sensors/{sensorID}")
def update_sensor_info(sensorID: int,
                        sensor: Sensor,
                        db: sqlite3.Connection = Depends(get_db)):
  db.execute('''
      UPDATE Sensor 
      SET doorID=?, sensor_type=?, date_installed=?
      WHERE sensorID=?
      ''',
      [
          sensor.doorID,
          sensor.sensor_type,
          sensor.date_installed,
          sensorID
      ])
  db.commit()
  return Response(None, status_code=204)
  
@app.post("/sensors")
def add_sensor_info(sensor: Sensor,
                    db: sqlite3.Connection = Depends(get_db)):
  try:
    db.execute('INSERT INTO Sensor VALUES (?,?,?,?)',
        [
          sensor.sensorID,
          sensor.doorID,
          sensor.sensor_type,
          sensor.date_installed
        ])
    db.commit()
  except sqlite3.IntegrityError:
    return "ERROR: sqlite3 Integrity Error"
  return Response(None, status_code=201)
  
# get repaired sensor info
@app.get("/repaired-sensors/{sensorID}")
def get_repaired_sensor_info(sensorID: int, db: sqlite3.Connection = Depends(get_db)):
  rows = db.execute("SELECT * FROM v_RepairedSensor WHERE sensorID=?",
                          [sensorID]).fetchall()
  return {'repaired_sensors' : rows}

@app.put("repaired-sensor/{sensorID}")
def update_repaired_sensor_info(sensorID: int, 
                                  repaired_sensor: RepairedSensor,
                                  db: sqlite3.Connection = Depends(get_db)):
  db.execute('''
      UPDATE RepairedSensor
      SET technicianID=?, dateDown=?, dateRestored=?, cause=?, repair=?
      WHERE sensorID=?
      ''',
      [
        repaired_sensor.technicianID,
        repaired_sensor.dateDown,
        repaired_sensor.dateRestored,
        repaired_sensor.cause,
        repaired_sensor.repair,
        sensorID
      ])

@app.post("/repaired-sensors")
def add_repaired_sensor_info(repaired_sensor: RepairedSensor, 
                             db: sqlite3.Connection = Depends(get_db)):
  try:
    db.execute('INSERT INTO RepairedSensor VALUES (?,?,?,?,?,?)',
        [
          repaired_sensor.sensorID,
          repaired_sensor.technicianID,
          repaired_sensor.dateDown,
          repaired_sensor.dateRestored,
          repaired_sensor.cause,
          repaired_sensor.repair
        ])
    db.commit()
  except sqlite3.IntegrityError:
    return 'ERROR: sqlite3 Integrity Error'
  return Response(None, status_code=201)
  
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
  
  
  
  
  
  
  
  
  
  
  
