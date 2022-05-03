-- QUESTION: store date as TEXT or DATETIME?
-- employee ID: 1-50, supervisorID 20, technicianID: 30, taxpayerID: 40
-- drug test ID: 51-100
-- badge ID: 100-200
-- sensor ID: 200-300
-- location ID: 300-400
-- room ID: 400-500
-- office ID: 500-600
-- building ID: 600-700
-- school ID: 700-800
DROP TABLE IF EXISTS Badge;
CREATE TABLE Badge(
  badgeID INT PRIMARY KEY, 
  mainGateTimes TIME,
  earliestEntry TIME,
  latestDeparture TIME
);
INSERT INTO Badge VALUES (51, '06:00', '06:00', '18:00');

DROP TABLE IF EXISTS Building;
CREATE TABLE Building(
  buildingID INT PRIMARY KEY,
  floor INT,
  roomID INT,
  door TEXT,
  FOREIGN KEY (roomID) REFERENCES TrackByRoom(roomID)
);
INSERT INTO Building VALUES (601, 2, 401, 'WEST');

DROP TABLE IF EXISTS BuildingAccessTimes;
CREATE TABLE BuildingAccessTimes(
  roomID INT PRIMARY KEY,
  floor INT,
  startTime TIME,
  endTime TIME
);
INSERT INTO BuildingAccessTimes VALUES (401, 2, '7:00', '17:00');

DROP TABLE IF EXISTS Director;
CREATE TABLE Director(
  employeeID INT PRIMARY KEY,
  name VARCHAR(30),
  directorStart DATE,
  directorEnd DATE
);
INSERT INTO Director VALUES (30, 'Chris Nolan', '02-22-2022', '04-10-2022');

DROP TABLE IF EXISTS DrugTest;
CREATE TABLE DrugTest(  
  labTestID INT PRIMARY KEY,
  date DATE,
  lab_used TEXT,
  test_used TEXT,
  results BOOLEAN,
  comments TEXT
);
INSERT INTO DrugTest VALUES (51, '4-20-2022', 'THE LAB', 'Urine test', 1, 
  'Positive for everything');

DROP TABLE IF EXISTS Education;
CREATE TABLE Education(
  schoolID INT PRIMARY KEY,
  startDate DATE,
  endDate DATE,
  degree TEXT,
  GPA FLOAT
);
INSERT INTO Education VALUES (701, '08-01-2017', '30-05-2021', 
  'Bachelor in Computer Science', 2.45);

DROP TABLE IF EXISTS EmployeeAccessRights;
CREATE TABLE EmployeeAccessRights(
  employeeID INT PRIMARY KEY,
  securityClearance TEXT,
  title TEXT
);
INSERT INTO EmployeeAccessRights VALUES (1, 'TOP SECRET', 'Employee title');

DROP TABLE IF EXISTS EmployeeBadge;
CREATE TABLE EmployeeBadge(
  employeeID INT PRIMARY KEY, 
  badgeID INT,
  FOREIGN KEY(badgeID) REFERENCES Badge(badgeID)
);
INSERT INTO EmployeeBadge VALUES (1, 100);

DROP TABLE IF EXISTS EmployeeDrugTest;
CREATE TABLE EmployeeDrugTest(
  employeeID INT,
  labTestID INT,
  PRIMARY KEY (employeeID, labTestID),
  FOREIGN KEY (employeeID) REFERENCES Employees(employeeID)
);
INSERT INTO EmployeeDrugTest VALUES (1, 51);

DROP TABLE IF EXISTS EmployeeEducation;
CREATE TABLE EmployeeEducation(
  employeeID INT,
  schoolID INT,
  PRIMARY KEY (employeeID, schoolID),
  FOREIGN KEY (employeeID) REFERENCES Employees(employeeID),
  FOREIGN KEY (schoolID) REFERENCES Education(schoolID)
);
INSERT INTO EmployeeEducation VALUES (1, 701);

DROP TABLE IF EXISTS EmployeeLocation;
CREATE TABLE EmployeeLocation(
  employeeID INT,
  locationID INT,
  PRIMARY KEY (employeeID, locationID),
  FOREIGN KEY (LocationID) REFERENCES Location(LocationID)
);
INSERT INTO EmployeeLocation VALUES (1, 301);

DROP TABLE IF EXISTS Employees ;
CREATE TABLE Employees(
  employeeID INT PRIMARY KEY,
  locationID INT,
  supervisorID INT, 
  title TEXT, --NOTE: 3NF
  taxpayer_id INT, 
  securityClearance TEXT, -- 3NF
  date_hired DATE,
  phone CHAR(10),
  dob DATE,
  FOREIGN KEY(locationID) REFERENCES Location(locationID),
  FOREIGN KEY(supervisorID) REFERENCES Supervisor(supervisorID)
);
INSERT INTO Employees VALUES (1, 301, 21, 'worker', 41, 'LOW', '04-10-2022', '5551234567', '01-01-2000');

DROP TABLE IF EXISTS Location;
CREATE TABLE Location(
  locationID INT PRIMARY KEY,
  address VARCHAR(30),
  city VARCHAR(20),
  state CHAR(2),
  zip CHAR(5)
);
INSERT INTO Location VALUES (301, '1234 Main St', 'Fullerton', 'CA', '92345');

DROP TABLE IF EXISTS Office;
CREATE TABLE Office(
  officeID INT PRIMARY KEY,
  phone CHAR(10),
  cellPhone CHAR(10)
);
INSERT INTO Office VALUES (501, '5552345678', '5552345688');

DROP TABLE IF EXISTS RepairedSensors;
CREATE TABLE RepairedSensors(
  sensorID INT PRIMARY KEY,
  technicianID INT,
  dateDown DATE,
  dateRestored DATE,
  FOREIGN KEY (technicianID) REFERENCES Technician(technicianID)
);
INSERT INTO RepairedSensors VALUES (201, 31, '4-12-2022', '4-15-2022');
INSERT INTO RepairedSensors VALUES (202, 31, '4-14-2022', '4-20-2022');

DROP TABLE IF EXISTS Sensor;
CREATE TABLE Sensor(
  sensorID INT PRIMARY KEY,
  sensor_type TEXT,
  date_installed DATE
);
INSERT INTO Sensor VALUES (201, 'Door sensor', '4-04-2022');

DROP TABLE IF EXISTS SensorActivations;
CREATE TABLE SensorActivations(
  sensorID INT,
  badgeID INT,
  date DATE,
  time TIME,
  direction VARCHAR(5),
  PRIMARY KEY (sensorID, badgeID, date, time, direction)
);
INSERT INTO SensorActivations VALUES (201, 101, '4-12-2022', '7:12', 'in');
INSERT INTO SensorActivations VALUES (201, 101, '4-12-2022', '16:02', 'out');
INSERT INTO SensorActivations VALUES (201, 101, '4-13-2022', '7:13', 'in');
INSERT INTO SensorActivations VALUES (201, 101, '4-12-2022', '16:03', 'out');
INSERT INTO SensorActivations VALUES (201, 101, '4-14-2022', '7:14', 'in');
INSERT INTO SensorActivations VALUES (201, 101, '4-12-2022', '16:04', 'out');
INSERT INTO SensorActivations VALUES (201, 101, '4-15-2022', '7:15', 'in');
INSERT INTO SensorActivations VALUES (201, 101, '4-12-2022', '16:05', 'out');

DROP TABLE IF EXISTS SensoredBuilding;
CREATE TABLE SensoredBuilding(
  sensorID int,
  buildingID int,
  PRIMARY KEY (sensorID, buildingID),
  FOREIGN KEY (sensorID) REFERENCES Sensor(sensorID),
  FOREIGN KEY (buildingID) REFERENCES Building(buildingID)
);
INSERT INTO SensoredBuilding VALUES (201, 601);
INSERT INTO SensoredBuilding VALUES (202, 601);
INSERT INTO SensoredBuilding VALUES (203, 601);
INSERT INTO SensoredBuilding VALUES (201, 602);
INSERT INTO SensoredBuilding VALUES (202, 602);
INSERT INTO SensoredBuilding VALUES (201, 603);

DROP TABLE IF EXISTS Supervisor;
CREATE TABLE Supervisor(
  employeeID INT,
  supervisorID INT PRIMARY KEY, 
  title VARCHAR(15),
  name VARCHAR(30),
  department VARCHAR(20),
  FOREIGN KEY(employeeID) REFERENCES Employees(employeeID)
);
INSERT INTO Supervisor VALUES (1, 21, 'Supervisor', 
  'Super Visorman', 'Drug Enforcement');

DROP TABLE IF EXISTS Technician;
CREATE TABLE Technician(
  employeeID INT,
  technicianID INT PRIMARY KEY,
  title TEXT,
  name VARCHAR(30),
  cause TEXT,
  repair TEXT,
  FOREIGN KEY (employeeID) REFERENCES Employees(employeeID)
);
INSERT INTO Technician VALUES (31, 31, 'Electrician', 'Jamie Foxx', 'Broken sensor', 'Repaired broken sensor');

DROP TABLE IF EXISTS TrackingLog;
CREATE TABLE TrackingLog(
  employeeID INT PRIMARY KEY,
  officeID INT,
  startPeriod DATE,
  endPeriod DATE,
  FOREIGN KEY (officeID) REFERENCES Office(officeID)
);
INSERT INTO TrackingLog VALUES (1, 1000, '04-01-2022', '04-10-2022');

DROP TABLE IF EXISTS TrackByRoom;
CREATE TABLE TrackByRoom(
  employeeID INT,
  roomID INT,
  PRIMARY KEY (employeeID, roomID),
  FOREIGN KEY (employeeID) REFERENCES Employees(employeeID)
);
INSERT INTO TrackByRoom VALUES (1, 401);
INSERT INTO TrackByRoom VALUES (1, 402);
INSERT INTO TrackByRoom VALUES (1, 403);
INSERT INTO TrackByRoom VALUES (1, 404);
INSERT INTO TrackByRoom VALUES (2, 401);
INSERT INTO TrackByRoom VALUES (2, 402);
