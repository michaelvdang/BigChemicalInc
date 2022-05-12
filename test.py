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
  degrees: list[Degree]
