-- QUESTION: store date as TEXT or DATETIME?
-- employee ID: 1-50, supervisorID: 21, technicianID: 31, taxpayerID: 41, directorID: 51
-- drug test ID: 51-100
-- badge ID: 101-200
-- sensor ID: 201-250
-- door ID: 251-300
-- location ID: 301-400
-- room ID: 401-500
-- office ID: 501-600
-- building ID: 601-700
-- school ID: 701-800

DROP TABLE IF EXISTS Badge;
CREATE TABLE Badge(
  badgeID INT PRIMARY KEY, 
  -- mainGateTimes TIME,
  earliestEntry TIME,
  latestDeparture TIME
);
INSERT INTO Badge VALUES (101, '06:00', '18:00');
INSERT INTO Badge VALUES (102, '06:00', '18:00');
INSERT INTO Badge VALUES (103, '06:00', '18:00');
INSERT INTO Badge VALUES (104, '06:00', '18:00');
INSERT INTO Badge VALUES (105, '06:00', '18:00');


DROP TABLE IF EXISTS Building;
CREATE TABLE Building(
  buildingID int PRIMARY KEY,
  name VARCHAR(20),
  FOREIGN KEY (buildingID) REFERENCES Building(buildingID)
);
INSERT INTO Building VALUES (601, 'Administration');
INSERT INTO Building VALUES (602, 'Factory');
INSERT INTO Building VALUES (603, 'Garage');
INSERT INTO Building VALUES (604, 'Warehouse');
INSERT INTO Building VALUES (605, 'Parking');

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
INSERT INTO Director VALUES (31, 'Kenny', '02-22-2022', '04-10-2022');

DROP TABLE IF EXISTS Door;
CREATE TABLE Door(
  doorID INT PRIMARY KEY,
  buildingID INT,
  floor INT,
  roomID INT,
  description VARCHAR(20),
  FOREIGN KEY (roomID) REFERENCES TrackByRoom(roomID)
);
INSERT INTO Door VALUES (251, 601, 2, 401, 'WEST');
INSERT INTO Door VALUES (252, 601, 2, 401, 'NORTH');
INSERT INTO Door VALUES (253, 601, 2, 401, 'SOUTH');
INSERT INTO Door VALUES (254, 601, 2, 401, 'EAST');

DROP TABLE IF EXISTS DrugTest;
CREATE TABLE DrugTest(  
  labTestID INT PRIMARY KEY,
  date DATE,
  lab_used TEXT,
  test_used TEXT,
  results BOOLEAN,
  comments TEXT
);
INSERT INTO DrugTest VALUES (51, '04-20-2022', 'THE LAB', 'Urine test', 1, 
  'Positive for everything');

DROP TABLE IF EXISTS Education;
CREATE TABLE Education(
  schoolID INT PRIMARY KEY,
  school_name VARCHAR(20),
  startDate DATE,
  endDate DATE,
  degree TEXT,
  GPA FLOAT
);
INSERT INTO Education VALUES (701, 'CSU Fullerton', '08-01-2017', '30-05-2021', 
  'Bachelor in Computer Science', 2.45);

DROP TABLE IF EXISTS Employee;
CREATE TABLE Employee(
  employeeID INT PRIMARY KEY,
  locationID INT,
  supervisorID INT, 
  name VARCHAR(30),
  title TEXT, --NOTE: 3NF
  department VARCHAR(20),
  taxpayer_id INT, 
  securityClearance TEXT, -- 3NF
  date_hired DATE,
  phone CHAR(10),
  dob DATE,
  FOREIGN KEY(locationID) REFERENCES Location(locationID),
  FOREIGN KEY(supervisorID) REFERENCES Supervisor(employeeID)
);
INSERT INTO Employee VALUES (1, 301, 21, 'Kyle', 'worker', 'Accounting', 41, 'LOW', '04-10-2022', '5551234567', '01-01-1997');
INSERT INTO Employee VALUES (21, 301, 21, 'Eric', 'Supervisor', 'Accounting', 42, 'MID', '02-15-2020', '5551234568', '01-01-1998');
INSERT INTO Employee VALUES (31, 301, 21, 'Stan', 'Technician', 'Technology', 43, 'MID', '03-15-2018', '5551234569', '01-01-1997');
INSERT INTO Employee VALUES (51, 301, 21, 'Kenny', 'Director', 'Accounting', 44, 'HIGH', '02-22-2022', '5551234570', '01-01-1997');

DROP TABLE IF EXISTS EmployeeAccessRights;
CREATE TABLE EmployeeAccessRights(
  employeeID INT,
  -- securityClearance TEXT,
  -- title TEXT
  roomID INT,
  startTime TIME,
  endTime TIME,
  directorID INT, 
  startDate DATE,
  endDate DATE,
  PRIMARY KEY (employeeID, roomID)
  FOREIGN KEY (directorID) REFERENCES Director(employeeID)
);
-- INSERT INTO EmployeeAccessRights VALUES (1, 'TOP SECRET', 'Employee title');
INSERT INTO EmployeeAccessRights VALUES (1, 401, '7:00', '17:00',
                                        51, '05-01-2022', '05-31-2022');
INSERT INTO EmployeeAccessRights VALUES (1, 402, '7:00', '17:00',
                                        51, '05-01-2022', '05-31-2022');
INSERT INTO EmployeeAccessRights VALUES (1, 403, '7:00', '17:00',
                                        51, '05-01-2022', '05-31-2022');
INSERT INTO EmployeeAccessRights VALUES (21, 401, '5:00', '19:00',
                                        51, '05-01-2022', '05-31-2022');
INSERT INTO EmployeeAccessRights VALUES (21, 402, '5:00', '19:00',
                                        51, '05-01-2022', '05-31-2022');
INSERT INTO EmployeeAccessRights VALUES (21, 403, '5:00', '19:00',
                                        51, '05-01-2022', '05-31-2022');
INSERT INTO EmployeeAccessRights VALUES (51, 401, '0:00', '0:00',
                                        51, '05-01-2022', '05-31-2022');
INSERT INTO EmployeeAccessRights VALUES (51, 402, '0:00', '0:00',
                                        51, '05-01-2022', '05-31-2022');
INSERT INTO EmployeeAccessRights VALUES (51, 403, '0:00', '0:00',
                                        51, '05-01-2022', '05-31-2022');


DROP TABLE IF EXISTS EmployeeBadge;
CREATE TABLE EmployeeBadge(
  employeeID INT PRIMARY KEY, 
  badgeID INT,
  FOREIGN KEY(badgeID) REFERENCES Badge(badgeID)
);
INSERT INTO EmployeeBadge VALUES (1, 101);
INSERT INTO EmployeeBadge VALUES (21, 102);
INSERT INTO EmployeeBadge VALUES (31, 103);
INSERT INTO EmployeeBadge VALUES (51, 104);

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
  cause VARCHAR(30),
  repair VARCHAR(30),
  FOREIGN KEY (technicianID) REFERENCES Technician(technicianID)
);
INSERT INTO RepairedSensors VALUES (201, 31, '04-12-2022', '04-15-2022', 'sensor fell out', 'reinstalled with glue');
INSERT INTO RepairedSensors VALUES (202, 31, '04-14-2022', '04-20-2022', 'broken sensor', 'replaced');

DROP TABLE IF EXISTS Sensor;
CREATE TABLE Sensor(
  sensorID INT PRIMARY KEY,
  doorID INT, 
  sensor_type VARCHAR(20),
  date_installed DATE,
  FOREIGN KEY (doorID) REFERENCES Door(doorID)
);
INSERT INTO Sensor VALUES (201, 251, 'Door sensor', '04-04-2022');
INSERT INTO Sensor VALUES (202, 252, 'Door sensor', '04-04-2022');
INSERT INTO Sensor VALUES (203, 253, 'Door sensor', '04-04-2022');
INSERT INTO Sensor VALUES (204, 254, 'Door sensor', '04-04-2022');
INSERT INTO Sensor VALUES (205, 255, 'Door sensor', '04-04-2022');
INSERT INTO Sensor VALUES (206, 256, 'Door sensor', '04-04-2022');
INSERT INTO Sensor VALUES (207, 257, 'Door sensor', '04-04-2022');

DROP TABLE IF EXISTS SensorActivations;
CREATE TABLE SensorActivations(
  sensorID INT,
  badgeID INT,
  date DATE,
  time TIME,
  direction VARCHAR(5),
  PRIMARY KEY (sensorID, badgeID, date, time, direction)
);
INSERT INTO SensorActivations VALUES (201, 101, '04-12-2022', '07:12', 'in');
INSERT INTO SensorActivations VALUES (201, 101, '04-12-2022', '16:02', 'out');
INSERT INTO SensorActivations VALUES (201, 101, '04-13-2022', '07:13', 'in');
INSERT INTO SensorActivations VALUES (201, 101, '04-13-2022', '16:03', 'out');
INSERT INTO SensorActivations VALUES (201, 101, '04-14-2022', '07:14', 'in');
INSERT INTO SensorActivations VALUES (201, 101, '04-14-2022', '16:04', 'out');
INSERT INTO SensorActivations VALUES (201, 101, '04-15-2022', '07:15', 'in');
INSERT INTO SensorActivations VALUES (201, 101, '04-15-2022', '16:05', 'out');
INSERT INTO SensorActivations VALUES (201, 102, '04-18-2022', '07:05', 'in');
INSERT INTO SensorActivations VALUES (201, 102, '04-18-2022', '16:02', 'out');
INSERT INTO SensorActivations VALUES (201, 102, '04-19-2022', '07:13', 'in');
INSERT INTO SensorActivations VALUES (201, 102, '04-19-2022', '16:03', 'out');
INSERT INTO SensorActivations VALUES (201, 102, '04-20-2022', '07:14', 'in');
INSERT INTO SensorActivations VALUES (201, 102, '04-20-2022', '16:04', 'out');
INSERT INTO SensorActivations VALUES (201, 102, '04-21-2022', '07:15', 'in');
INSERT INTO SensorActivations VALUES (201, 102, '04-21-2022', '16:05', 'out');

DROP TABLE IF EXISTS Supervisor;
CREATE TABLE Supervisor(
  employeeID INT,
  -- supervisorID INT PRIMARY KEY, 
  title VARCHAR(15),
  name VARCHAR(30),
  department VARCHAR(20),
  FOREIGN KEY(employeeID) REFERENCES Employees(employeeID)
);
INSERT INTO Supervisor VALUES (21, 'Supervisor', 
  'Eric', 'Drug Enforcement');

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
