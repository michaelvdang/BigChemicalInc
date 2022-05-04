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

DROP VIEW IF EXISTS v_SensorInfo;
CREATE VIEW v_SensorInfo AS
SELECT sensorID, name, floor, roomID, description
        sensor_type, date_installed
FROM Sensor s
JOIN Door d               ON s.doorID=d.doorID
JOIN Building b           ON d.buildingID=b.buildingID;

DROP VIEW IF EXISTS v_RepairedSensors;
CREATE VIEW v_RepairedSensors AS
SELECT rs.sensorID AS sensorID, dateDown, dateRestored,
        t.name AS technician, rs.cause, rs.repair
FROM RepairedSensors rs
JOIN Technician t         ON rs.technicianID=t.technicianID;

-- Employee accesses can't create view because we need wild cards
-- use python for this
SELECT e.name AS name, b.name AS building, roomID, d.doorID, 
                  date, time, direction
FROM SensorActivations sa
JOIN Sensor s                   ON sa.sensorID=s.sensorID
JOIN Door d                     ON s.doorID=d.doorID
JOIN Building b                 ON d.buildingID=b.buildingID
JOIN EmployeeBadge eb           ON eb.badgeID=sa.badgeID
JOIN Employee e                 ON eb.employeeID=e.employeeID
WHERE date BETWEEN '04-13-2022' AND '04-14-2022'
ORDER BY date;

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