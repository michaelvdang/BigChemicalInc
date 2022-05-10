from pydantic import BaseModel
from typing import List


class Degree(BaseModel):
  # employeeID: int
  school_name: str
  startDate: str
  endDate: str
  degree_name: str
  GPA: float


class Education(BaseModel):
  # employeeID: int
  degrees: list[Degree] = []


class Employee(BaseModel):
  employeeID: int
  supervisorID: int
  name: str
  title: str
  department: str
  taxpayer_id: int
  securityClearance: str
  date_hired: str
  phone: str
  dob: str

class Address(BaseModel):
  # employeeID: int
  address: str
  city: str
  state: str
  zip: str


class DrugTest(BaseModel):
  employeeID: int
  date: str
  lab_used: str
  test_used: str
  labTestID: int
  results: bool
  comments: str

class Sensor(BaseModel):
  sensorID: int
  doorID: int
  sensor_type: str
  date_installed: str

class RepairedSensor(BaseModel):
  sensorID: int
  technicianID: int
  dateDown: str
  dateRestored: str
  # technician_name: str
  cause: str
  repair: str
