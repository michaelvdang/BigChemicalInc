DROP VIEW IF EXISTS v_EmployeeInfo;
CREATE VIEW v_EmployeeInfo AS
SELECT e.employeeID AS employeeID, e.name AS name, 
      taxpayer_id, date_hired, e.department, 
      address, city, state, zip, phone, s.name AS [supervisor]
      -- ,school_name, startDate, endDate, degree, GPA
FROM Employee e 
LEFT JOIN Address l                ON e.employeeID=l.employeeID
-- LEFT JOIN EmployeeEducation ee      ON e.employeeID=ee.employeeID
-- LEFT JOIN Education ed              ON ee.schoolID=ed.schoolID
LEFT JOIN Supervisor s              ON e.supervisorID=s.employeeID
;

DROP VIEW IF EXISTS v_DrugTestResult;
CREATE VIEW v_DrugTestResult AS
SELECT e.employeeID AS employeeID,
      date, lab_used, test_used, dt.labTestID as labTestID,
      results, comments
FROM Employee e
-- LEFT JOIN EmployeeDrugTest edt       ON e.employeeID=edt.employeeID
-- LEFT JOIN DrugTest dt                ON edt.labTestID=dt.labTestID;
LEFT JOIN DrugTest dt                   ON dt.employeeID=e.employeeID;

DROP VIEW IF EXISTS v_SensorInfo;
CREATE VIEW v_SensorInfo AS
SELECT sensorID, name, floor, roomID, description,
        sensor_type, date_installed
FROM Sensor s
LEFT JOIN Door d               ON s.doorID=d.doorID
LEFT JOIN Building b           ON d.buildingID=b.buildingID;

DROP VIEW IF EXISTS v_SensorRepair;
CREATE VIEW v_SensorRepair AS
SELECT rs.sensorID AS sensorID, dateDown, dateRestored,
        t.name AS technician_name, rs.cause, rs.repair
FROM SensorRepair rs
LEFT JOIN Technician t         ON rs.technicianID=t.technicianID;

CREATE VIEW v_EmployeeAccess AS
SELECT e.employeeID AS employeeID, e.name AS name, 
      b.name AS building, roomID, d.doorID, 
      date, time, direction
FROM SensorActivation sa
JOIN Sensor s                   ON sa.sensorID=s.sensorID
JOIN Door d                     ON s.doorID=d.doorID
JOIN Building b                 ON d.buildingID=b.buildingID
JOIN EmployeeBadge eb           ON eb.badgeID=sa.badgeID
JOIN Employee e                 ON eb.employeeID=e.employeeID
ORDER BY e.name, date
;
-- WHERE date BETWEEN '04-13-2022' AND '04-14-2022'
-- ORDER BY date;

DROP VIEW IF EXISTS v_EmployeeAccessRights;
CREATE VIEW v_EmployeeAccessRights AS
SELECT DISTINCT e.employeeID AS employeeID, e.name AS name, securityClearance, title, 
      eb.badgeID AS badgeID, earliestEntry, latestDeparture, 
      buildingID, floor, ear.roomID AS roomID,
      startTime, endTime, di.name AS [director_name], startDate, endDate
FROM EmployeeAccessRights ear
JOIN Employee e                   ON e.employeeID=ear.employeeID
JOIN EmployeeBadge eb             ON e.employeeID=eb.employeeID
JOIN Badge ba                     ON eb.badgeID=ba.badgeID
JOIN Door do                      ON ear.roomID=do.roomID
LEFT JOIN Director di             ON di.employeeID=ear.directorID;