from audioop import add
from typing import Optional, List
import sqlite3
from fastapi import Body, FastAPI, Depends, Response
from pydantic import BaseModel
from starlette.middleware.cors import CORSMiddleware
import contextlib
from models.my_models import Degree, Education, Employee, Address, SensorRepair, Sensor, DrugTest

app = FastAPI()

origins = [
    "http://localhost:4200",
    # "localhost:4200",
    # "http://localhost:*",
    # "http://127.0.0.1:4200"
]

app.add_middleware(
    CORSMiddleware,
    allow_origins='*',
    # allow_credentials=True,
    allow_methods=["*"], # does this work ?
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
  if employee_info:
    employee_education = db.execute('SELECT * FROM Education WHERE employeeID=?',
                                [employeeID]).fetchall()
    return {'employee_info': employee_info, 'employee_education': employee_education}
  else:
    return {Response(None, status_code=404)}
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
            date_hired=?, phone=?, dob=?, deleted=false
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
                    date_hired, phone, dob, deleted) 
        VALUES (?,?,?,?,?,?,?,?,?,?, false)
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

@app.delete("/employees/{employeeID}")
def delete_employee(employeeID: int, db: sqlite3.Connection = Depends(get_db)):
  db.execute('UPDATE Employee SET deleted=1 WHERE employeeID=?', [employeeID])
  db.commit()
  return

# get employee test results
# must create TestResult class
@app.get("/employees/{employeeID}/drug-test-results")
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

@app.post("/employees/{employeeID}/drug-test-results")
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
@app.get("/sensors")
def get_sensor_info(db: sqlite3.Connection = Depends(get_db)):
  rows = db.execute("SELECT * FROM v_SensorInfo").fetchall()
  return {'sensors' : rows}

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
    db.execute('INSERT INTO Sensor VALUES (?,?,?,?, false)',
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
@app.get("/sensor-repairs/{sensorID}")
def get_sensor_repair_info(sensorID: int, db: sqlite3.Connection = Depends(get_db)):
  rows = db.execute("SELECT * FROM v_SensorRepair WHERE sensorID=?",
                          [sensorID]).fetchall()
  return {'sensor_repairs' : rows}

@app.put("/sensor-repairs/{sensorID}")
def update_sensor_repair_info(sensorID: int, 
                                  sensor_repair: SensorRepair,
                                  db: sqlite3.Connection = Depends(get_db)):
  db.execute('''
      UPDATE SensorRepair
      SET technicianID=?, dateDown=?, dateRestored=?, cause=?, repair=?
      WHERE sensorID=?
      ''',
      [
        sensor_repair.technicianID,
        sensor_repair.dateDown,
        sensor_repair.dateRestored,
        sensor_repair.cause,
        sensor_repair.repair,
        sensorID
      ])

@app.post("/sensor-repairs")
def add_sensor_repair_info(sensor_repair: SensorRepair, 
                             db: sqlite3.Connection = Depends(get_db)):
  try:
    db.execute('INSERT INTO SensorRepair VALUES (?,?,?,?,?,?)',
        [
          sensor_repair.sensorID,
          sensor_repair.technicianID,
          sensor_repair.dateDown,
          sensor_repair.dateRestored,
          sensor_repair.cause,
          sensor_repair.repair
        ])
    db.commit()
  except sqlite3.IntegrityError:
    return 'ERROR: sqlite3 Integrity Error'
  return Response(None, status_code=201)
  
# get employee accesses
@app.get("/tracking-log/{employeeID}")#?startDate={startDate}&endDate={endDate}")
def get_tracking_log(employeeID: int, 
                          startDate: str,
                          endDate: str,
                          db: sqlite3.Connection = Depends(get_db)):
  accesses = db.execute("""SELECT * 
                            FROM v_EmployeeAccess 
                            WHERE employeeID=?
                            AND date 
                            BETWEEN ? AND ?""",
                          [employeeID, startDate, endDate])
  office_info = db.execute('''SELECT o.officeID AS officeID, o.phone, cellPhone 
                              FROM Employee e
                              JOIN TrackingLog tl ON tl.employeeID=e.employeeID
                              JOIN Office o       ON o.officeID=tl.officeID
                              WHERE e.employeeID=?
                            ''', [employeeID])
  return {'office_info': office_info.fetchone(), 'accesses': accesses.fetchall(), }

@app.get("/sensor-activations")
def get_sensor_activations(db: sqlite3.Connection = Depends(get_db)):
  sensor_activations = db.execute('SELECT * FROM SensorActivation')
  return {'sensor_activations' : sensor_activations.fetchall()}

# get employee access rights
@app.get("/employee-access-rights/{employeeID}")
def get_employee_access_rights(employeeID: int, db: sqlite3.Connection = Depends(get_db)):
  access_rights = db.execute('''
                              SELECT * 
                              FROM v_EmployeeAccessRights
                              WHERE employeeID=?
                              ''', [employeeID])
  return {'access_rights' : access_rights.fetchall()}
  
  
  
  
  
  
  
  
  
  
  
