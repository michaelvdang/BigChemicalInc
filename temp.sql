EmployeeAccessRights

name, securityClearance, title, badgeID,
earliestEntry, latestDeparture,
buildingID, floor, roomID

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