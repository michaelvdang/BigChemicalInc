DROP VIEW IF EXISTS v_EmployeeInfo;
CREATE VIEW v_EmployeeInfo AS
  SELECT e.employeeID AS employeeID, e.name AS name, 
        taxpayer_id, date_hired, e.department, 
        address, city, state, zip, phone, s.name AS [supervisor], 
        school_name, startDate, endDate, degree, GPA
  FROM Employee e 
    JOIN Location l           ON e.locationID=l.locationID
    JOIN EmployeeEducation ee ON e.employeeID=ee.employeeID
    JOIN Education ed         ON ee.schoolID=ed.schoolID
    JOIN Supervisor s         ON e.supervisorID=s.employeeID
;

DROP VIEW IF EXISTS v_DrugTestResults;
CREATE VIEW v_DrugTestResults AS
SELECT e.employeeID AS employeeID,
      date, lab_used, test_used, dt.labTestID as labTestID,
      results, comments
FROM Employee e
JOIN EmployeeDrugTest edt       ON e.employeeID=edt.employeeID
JOIN DrugTest dt                ON edt.labTestID=dt.labTestID;

-- Sensor information: cannot locate sensor with their ID

DROP VIEW IF EXISTS v_RepairedSensors;
CREATE VIEW v_RepairedSensors AS
SELECT rs.sensorID AS sensorID, dateDown, dateRestored,
        t.name AS technician, rs.cause, rs.repair
FROM RepairedSensors rs
JOIN Technician t         ON rs.technicianID=t.technicianID;

DROP VIEW IF EXISTS v_EmployeeAccessRights;
CREATE VIEW v_EmployeeAccessRights AS
SELECT e.name AS name, securityClearance, title, 
      eb.badgeID AS badgeID, earliestEntry, latestDeparture, 
      buildingID, floor, ear.roomID AS roomID
FROM Employee e 
JOIN EmployeeAccessRights ear     ON e.employeeID=ear.employeeID
JOIN EmployeeBadge eb             ON e.employeeID=eb.employeeID
JOIN Badge ba                     ON eb.badgeID=ba.badgeID
JOIN Door d                       ON ear.roomID=d.roomID;