Requirement: the user shall be able to retrieve information on employee
accesses detected by the sensors using the employeeID, start time, and
end time. The returned data will include 

sensorID, date, time, badgeID, direction

Form: the employeeID, start date and start time, end date and end time
are entered in the GET TRACKING INFO input screen. The system will 
return output on the TRACKING INFO screen, including the location,
time-in, time-out, door.

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