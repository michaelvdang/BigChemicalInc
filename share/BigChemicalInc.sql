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
-- degree ID: 701-800

DROP TABLE IF EXISTS Address;
CREATE TABLE Address(
  employeeID INT PRIMARY KEY,
  address VARCHAR(30),
  city VARCHAR(20),
  state CHAR(2),
  zip CHAR(5)
);
INSERT INTO Address VALUES (1, '1234 Main St', 'Fullerton', 'CA', '92345');


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
INSERT INTO Building VALUES (622, 'Factory');
INSERT INTO Building VALUES (633, 'Garage');
INSERT INTO Building VALUES (644, 'Warehouse');
INSERT INTO Building VALUES (655, 'Parking');


DROP TABLE IF EXISTS BuildingAccessTime;
CREATE TABLE BuildingAccessTime(
  roomID INT PRIMARY KEY,
  floor INT,
  startTime TIME,
  endTime TIME
);
INSERT INTO BuildingAccessTime VALUES (401, 2, '7:00', '17:00');

DROP TABLE IF EXISTS Director;
CREATE TABLE Director(
  employeeID INT PRIMARY KEY,
  name VARCHAR(30),
  directorStart DATE,
  directorEnd DATE
);
INSERT INTO Director VALUES (51, 'Kenny', '02-22-2022', '04-10-2022');


DROP TABLE IF EXISTS Door;
CREATE TABLE Door(
  doorID INT PRIMARY KEY,
  buildingID INT,
  floor INT,
  roomID INT,
  description VARCHAR(20)
  -- FOREIGN KEY (roomID) REFERENCES TrackByRoom(roomID)
);
INSERT INTO Door VALUES (251, 601, 1, 401, 'WEST');
INSERT INTO Door VALUES (252, 601, 1, 401, 'NORTH');
INSERT INTO Door VALUES (253, 601, 1, 401, 'SOUTH');
INSERT INTO Door VALUES (254, 601, 1, 401, 'EAST');
INSERT INTO Door VALUES (255, 601, 1, 402, 'WEST');
INSERT INTO Door VALUES (256, 601, 1, 403, 'EAST');
INSERT INTO Door VALUES (257, 601, 1, 404, 'SOUTH');
INSERT INTO Door VALUES (258, 622, 1, 422, 'NORTH');
INSERT INTO Door VALUES (259, 633, 1, 433, 'NORTH');
INSERT INTO Door VALUES (260, 644, 1, 444, 'WEST');
INSERT INTO Door VALUES (261, 655, 1, 455, 'EAST');
INSERT INTO Door VALUES (262, 666, 1, 466, 'SOUTH');


DROP TABLE IF EXISTS DrugTest;
CREATE TABLE DrugTest(
  employeeID INT,
  labTestID INT,
  date DATE,
  lab_used TEXT,
  test_used TEXT,
  results BOOLEAN,
  comments TEXT,
  PRIMARY KEY (employeeID, labTestID)
);
INSERT INTO DrugTest VALUES (1, 51, '04-20-2022', 'THE LAB', 'Urine test', 0, 
  'No comment');
INSERT INTO DrugTest VALUES (1, 52, '04-21-2022', 'THE LAB', 'Urine test', 0, 
  'No comment');
INSERT INTO DrugTest VALUES (1, 53, '04-22-2022', 'THE LAB', 'Urine test', 1, 
  'Tested positive');
INSERT INTO DrugTest VALUES (2, 54, '04-21-2022', 'THE LAB', 'Urine test', 1, 
  'Tested positive');
INSERT INTO DrugTest VALUES (2, 55, '04-22-2022', 'THE LAB', 'Urine test', 1, 
  'Tested positive');
INSERT INTO DrugTest VALUES (2, 56, '04-23-2022', 'THE LAB', 'Urine test', 1, 
  'Tested positive');


DROP TABLE IF EXISTS Education;
CREATE TABLE Education(
  employeeID INT,
  degree_name VARCHAR(30),
  school_name VARCHAR(20),
  startDate DATE,
  endDate DATE,
  GPA FLOAT,
  -- schoolID INT,
  PRIMARY KEY (employeeID, degree_name),
  FOREIGN KEY (employeeID) REFERENCES Employee(employeeID)
);
INSERT INTO Education VALUES (1, 'Bachelor in Computer Science',
        'CSU Fullerton', '08-01-2014', '05-30-2022', 2.50);
INSERT INTO Education VALUES (1, 'Masters in Computer Science',
        'CSU Fullerton', '08-01-2014', '05-30-2022', 2.60);
INSERT INTO Education VALUES (1, 'PhD in Computer Science',
        'CSU Fullerton', '08-01-2014', '05-30-2022', 2.70);
INSERT INTO Education VALUES (1, 'MBA',
        'CSU Fullerton', '08-01-2014', '05-30-2022', 2.80);


DROP TABLE IF EXISTS Employee;
CREATE TABLE Employee(
  employeeID INT PRIMARY KEY,
  -- locationID INT,
  supervisorID INT, 
  name VARCHAR(30),
  title TEXT, --NOTE: 3NF
  department VARCHAR(20),
  taxpayer_id INT, 
  securityClearance TEXT, -- 3NF
  date_hired DATE,
  phone CHAR(10),
  dob DATE,
  FOREIGN KEY(employeeID) REFERENCES Address(employeeID),
  FOREIGN KEY(supervisorID) REFERENCES Supervisor(employeeID),
  UNIQUE (employeeID, taxpayer_id)
);
INSERT INTO Employee VALUES (1, 21, 'Kyle', 'worker', 'Accounting', 41, 'LOW', '04-10-2022', '5551234567', '01-01-1997');
INSERT INTO Employee VALUES (21, 21, 'Eric', 'Supervisor', 'Accounting', 42, 'MID', '02-15-2020', '5551234568', '01-01-1998');
INSERT INTO Employee VALUES (31, 21, 'Stan', 'Technician', 'Technology', 43, 'MID', '03-15-2018', '5551234569', '01-01-1997');
INSERT INTO Employee VALUES (51, 21, 'Kenny', 'Director', 'Accounting', 44, 'HIGH', '02-22-2022', '5551234570', '01-01-1997');


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
INSERT INTO EmployeeAccessRights VALUES (1, 401, '08:15', '16:45',
                                        51, '02-01-2022', '08-31-2022');
INSERT INTO EmployeeAccessRights VALUES (1, 402, '07:30', '17:30',
                                        51, '04-01-2022', '07-31-2022');
INSERT INTO EmployeeAccessRights VALUES (1, 403, '07:00', '17:00',
                                        51, '05-01-2022', '05-31-2022');
INSERT INTO EmployeeAccessRights VALUES (1, 404, '07:30', '17:30',
                                        51, '05-01-2022', '05-15-2022');
INSERT INTO EmployeeAccessRights VALUES (1, 422, '07:45', '15:45',
                                        51, '04-01-2022', '07-31-2022');
INSERT INTO EmployeeAccessRights VALUES (1, 433, '07:15', '16:15',
                                        51, '05-01-2022', '05-31-2022');
INSERT INTO EmployeeAccessRights VALUES (21, 401, '05:00', '19:00',
                                        51, '05-01-2022', '05-31-2022');
INSERT INTO EmployeeAccessRights VALUES (21, 422, '05:00', '19:00',
                                        51, '05-01-2022', '05-31-2022');
INSERT INTO EmployeeAccessRights VALUES (21, 433, '05:00', '19:00',
                                        51, '05-01-2022', '05-31-2022');
INSERT INTO EmployeeAccessRights VALUES (51, 401, '00:00', '00:00',
                                        51, '05-01-2022', '05-31-2022');
INSERT INTO EmployeeAccessRights VALUES (51, 422, '00:00', '00:00',
                                        51, '05-01-2022', '05-31-2022');
INSERT INTO EmployeeAccessRights VALUES (51, 433, '00:00', '00:00',
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
  FOREIGN KEY (employeeID) REFERENCES Employee(employeeID)
);
INSERT INTO EmployeeDrugTest VALUES (1, 51);
INSERT INTO EmployeeDrugTest VALUES (1, 52);
INSERT INTO EmployeeDrugTest VALUES (1, 53);
INSERT INTO EmployeeDrugTest VALUES (31, 54);
INSERT INTO EmployeeDrugTest VALUES (31, 55);
INSERT INTO EmployeeDrugTest VALUES (31, 56);


DROP TABLE IF EXISTS Office;
CREATE TABLE Office(
  officeID INT PRIMARY KEY,
  phone CHAR(10),
  cellPhone CHAR(10)
);
INSERT INTO Office VALUES (501, '5552345678', '5552345688');


DROP TABLE IF EXISTS SensorRepair;
CREATE TABLE SensorRepair(
  sensorID INT PRIMARY KEY,
  technicianID INT NOT NULL,
  dateDown DATE,
  dateRestored DATE,
  cause VARCHAR(30),
  repair VARCHAR(30),
  FOREIGN KEY (technicianID) REFERENCES Technician(technicianID)
);
INSERT INTO SensorRepair VALUES (201, 31, '04-12-2022', '04-15-2022', 'sensor fell out', 'reinstalled with glue');
INSERT INTO SensorRepair VALUES (202, 31, '04-14-2022', '04-20-2022', 'broken sensor', 'replaced');

DROP TABLE IF EXISTS Sensor;
CREATE TABLE Sensor(
  sensorID INT PRIMARY KEY,
  doorID INT, 
  sensor_type VARCHAR(20),
  date_installed DATE,
  FOREIGN KEY (doorID) REFERENCES Door(doorID)
);
INSERT INTO Sensor VALUES (201, 251, 'Door sensor', '04-04-2021');
INSERT INTO Sensor VALUES (202, 252, 'Door sensor', '07-23-2021');
INSERT INTO Sensor VALUES (203, 253, 'Door sensor', '01-11-2021');
INSERT INTO Sensor VALUES (204, 254, 'Door sensor', '04-04-2021');
INSERT INTO Sensor VALUES (205, 255, 'Door sensor', '07-11-2021');
INSERT INTO Sensor VALUES (206, 256, 'Door sensor', '04-04-2021');
INSERT INTO Sensor VALUES (207, 257, 'Door sensor', '01-23-2021');
INSERT INTO Sensor VALUES (208, 258, 'Door sensor', '04-04-2021');
INSERT INTO Sensor VALUES (209, 259, 'Door sensor', '04-11-2021');
INSERT INTO Sensor VALUES (210, 260, 'Door sensor', '07-23-2021');
INSERT INTO Sensor VALUES (211, 261, 'Door sensor', '01-04-2021');
INSERT INTO Sensor VALUES (212, 262, 'Door sensor', '04-11-2021');


DROP TABLE IF EXISTS SensorActivation;
CREATE TABLE SensorActivation(
  sensorID INT,
  badgeID INT,
  date DATE,
  time TIME,
  direction VARCHAR(5),
  PRIMARY KEY (sensorID, badgeID, date, time, direction)
);
INSERT INTO SensorActivation VALUES (201, 101, '04-12-2022', '07:12', 'in');
INSERT INTO SensorActivation VALUES (201, 101, '04-12-2022', '16:02', 'out');
INSERT INTO SensorActivation VALUES (201, 101, '04-13-2022', '07:13', 'in');
INSERT INTO SensorActivation VALUES (201, 101, '04-13-2022', '16:03', 'out');
INSERT INTO SensorActivation VALUES (201, 101, '04-14-2022', '07:14', 'in');
INSERT INTO SensorActivation VALUES (201, 101, '04-14-2022', '16:04', 'out');
INSERT INTO SensorActivation VALUES (201, 101, '04-15-2022', '07:15', 'in');
INSERT INTO SensorActivation VALUES (201, 101, '04-15-2022', '16:05', 'out');
INSERT INTO SensorActivation VALUES (201, 102, '04-18-2022', '07:05', 'in');
INSERT INTO SensorActivation VALUES (201, 102, '04-18-2022', '16:02', 'out');
INSERT INTO SensorActivation VALUES (201, 102, '04-19-2022', '07:13', 'in');
INSERT INTO SensorActivation VALUES (201, 102, '04-19-2022', '16:03', 'out');
INSERT INTO SensorActivation VALUES (201, 102, '04-20-2022', '07:14', 'in');
INSERT INTO SensorActivation VALUES (201, 102, '04-20-2022', '16:04', 'out');
INSERT INTO SensorActivation VALUES (201, 102, '04-21-2022', '07:15', 'in');
INSERT INTO SensorActivation VALUES (201, 102, '04-21-2022', '16:05', 'out');
INSERT INTO SensorActivation VALUES (202, 101, '04-12-2022', '07:12', 'in');
INSERT INTO SensorActivation VALUES (202, 101, '04-12-2022', '16:02', 'out');
INSERT INTO SensorActivation VALUES (202, 101, '04-13-2022', '07:13', 'in');
INSERT INTO SensorActivation VALUES (202, 101, '04-13-2022', '16:03', 'out');
INSERT INTO SensorActivation VALUES (202, 101, '04-14-2022', '07:14', 'in');
INSERT INTO SensorActivation VALUES (202, 101, '04-14-2022', '16:04', 'out');
INSERT INTO SensorActivation VALUES (202, 101, '04-15-2022', '07:15', 'in');
INSERT INTO SensorActivation VALUES (202, 101, '04-15-2022', '16:05', 'out');
INSERT INTO SensorActivation VALUES (202, 102, '04-18-2022', '07:05', 'in');
INSERT INTO SensorActivation VALUES (202, 102, '04-18-2022', '16:02', 'out');
INSERT INTO SensorActivation VALUES (202, 102, '04-19-2022', '07:13', 'in');
INSERT INTO SensorActivation VALUES (202, 102, '04-19-2022', '16:03', 'out');
INSERT INTO SensorActivation VALUES (202, 102, '04-20-2022', '07:14', 'in');
INSERT INTO SensorActivation VALUES (202, 102, '04-20-2022', '16:04', 'out');
INSERT INTO SensorActivation VALUES (202, 102, '04-21-2022', '07:15', 'in');
INSERT INTO SensorActivation VALUES (202, 102, '04-21-2022', '16:05', 'out');
INSERT INTO SensorActivation VALUES (203, 101, '04-12-2022', '07:12', 'in');
INSERT INTO SensorActivation VALUES (203, 101, '04-12-2022', '16:02', 'out');
INSERT INTO SensorActivation VALUES (203, 101, '04-13-2022', '07:13', 'in');
INSERT INTO SensorActivation VALUES (203, 101, '04-13-2022', '16:03', 'out');
INSERT INTO SensorActivation VALUES (203, 101, '04-14-2022', '07:14', 'in');
INSERT INTO SensorActivation VALUES (203, 101, '04-14-2022', '16:04', 'out');
INSERT INTO SensorActivation VALUES (203, 101, '04-15-2022', '07:15', 'in');
INSERT INTO SensorActivation VALUES (203, 101, '04-15-2022', '16:05', 'out');
INSERT INTO SensorActivation VALUES (203, 102, '04-18-2022', '07:05', 'in');
INSERT INTO SensorActivation VALUES (203, 102, '04-18-2022', '16:02', 'out');
INSERT INTO SensorActivation VALUES (203, 102, '04-19-2022', '07:13', 'in');
INSERT INTO SensorActivation VALUES (203, 102, '04-19-2022', '16:03', 'out');
INSERT INTO SensorActivation VALUES (203, 102, '04-20-2022', '07:14', 'in');
INSERT INTO SensorActivation VALUES (203, 102, '04-20-2022', '16:04', 'out');
INSERT INTO SensorActivation VALUES (203, 102, '04-21-2022', '07:15', 'in');
INSERT INTO SensorActivation VALUES (203, 102, '04-21-2022', '16:05', 'out');
INSERT INTO SensorActivation VALUES (204, 101, '04-12-2022', '07:12', 'in');
INSERT INTO SensorActivation VALUES (204, 101, '04-12-2022', '16:02', 'out');
INSERT INTO SensorActivation VALUES (204, 101, '04-13-2022', '07:13', 'in');
INSERT INTO SensorActivation VALUES (204, 101, '04-13-2022', '16:03', 'out');
INSERT INTO SensorActivation VALUES (204, 101, '04-14-2022', '07:14', 'in');
INSERT INTO SensorActivation VALUES (204, 101, '04-14-2022', '16:04', 'out');
INSERT INTO SensorActivation VALUES (204, 101, '04-15-2022', '07:15', 'in');
INSERT INTO SensorActivation VALUES (204, 101, '04-15-2022', '16:05', 'out');
INSERT INTO SensorActivation VALUES (204, 102, '04-18-2022', '07:05', 'in');
INSERT INTO SensorActivation VALUES (204, 102, '04-18-2022', '16:02', 'out');
INSERT INTO SensorActivation VALUES (204, 102, '04-19-2022', '07:13', 'in');
INSERT INTO SensorActivation VALUES (204, 102, '04-19-2022', '16:03', 'out');
INSERT INTO SensorActivation VALUES (204, 102, '04-20-2022', '07:14', 'in');
INSERT INTO SensorActivation VALUES (204, 102, '04-20-2022', '16:04', 'out');
INSERT INTO SensorActivation VALUES (204, 102, '04-21-2022', '07:15', 'in');
INSERT INTO SensorActivation VALUES (204, 102, '04-21-2022', '16:05', 'out');
INSERT INTO SensorActivation VALUES (205, 101, '04-12-2022', '07:12', 'in');
INSERT INTO SensorActivation VALUES (205, 101, '04-12-2022', '16:02', 'out');
INSERT INTO SensorActivation VALUES (205, 101, '04-13-2022', '07:13', 'in');
INSERT INTO SensorActivation VALUES (205, 101, '04-13-2022', '16:03', 'out');
INSERT INTO SensorActivation VALUES (205, 101, '04-14-2022', '07:14', 'in');
INSERT INTO SensorActivation VALUES (205, 101, '04-14-2022', '16:04', 'out');
INSERT INTO SensorActivation VALUES (205, 101, '04-15-2022', '07:15', 'in');
INSERT INTO SensorActivation VALUES (205, 101, '04-15-2022', '16:05', 'out');
INSERT INTO SensorActivation VALUES (205, 102, '04-18-2022', '07:05', 'in');
INSERT INTO SensorActivation VALUES (205, 102, '04-18-2022', '16:02', 'out');
INSERT INTO SensorActivation VALUES (205, 102, '04-19-2022', '07:13', 'in');
INSERT INTO SensorActivation VALUES (205, 102, '04-19-2022', '16:03', 'out');
INSERT INTO SensorActivation VALUES (205, 102, '04-20-2022', '07:14', 'in');
INSERT INTO SensorActivation VALUES (205, 102, '04-20-2022', '16:04', 'out');
INSERT INTO SensorActivation VALUES (205, 102, '04-21-2022', '07:15', 'in');
INSERT INTO SensorActivation VALUES (205, 102, '04-21-2022', '16:05', 'out');
INSERT INTO SensorActivation VALUES (206, 101, '04-12-2022', '07:12', 'in');
INSERT INTO SensorActivation VALUES (206, 101, '04-12-2022', '16:02', 'out');
INSERT INTO SensorActivation VALUES (206, 101, '04-13-2022', '07:13', 'in');
INSERT INTO SensorActivation VALUES (206, 101, '04-13-2022', '16:03', 'out');
INSERT INTO SensorActivation VALUES (206, 101, '04-14-2022', '07:14', 'in');
INSERT INTO SensorActivation VALUES (206, 101, '04-14-2022', '16:04', 'out');
INSERT INTO SensorActivation VALUES (206, 101, '04-15-2022', '07:15', 'in');
INSERT INTO SensorActivation VALUES (206, 101, '04-15-2022', '16:05', 'out');
INSERT INTO SensorActivation VALUES (206, 102, '04-18-2022', '07:05', 'in');
INSERT INTO SensorActivation VALUES (206, 102, '04-18-2022', '16:02', 'out');
INSERT INTO SensorActivation VALUES (206, 102, '04-19-2022', '07:13', 'in');
INSERT INTO SensorActivation VALUES (206, 102, '04-19-2022', '16:03', 'out');
INSERT INTO SensorActivation VALUES (206, 102, '04-20-2022', '07:14', 'in');
INSERT INTO SensorActivation VALUES (206, 102, '04-20-2022', '16:04', 'out');
INSERT INTO SensorActivation VALUES (206, 102, '04-21-2022', '07:15', 'in');
INSERT INTO SensorActivation VALUES (206, 102, '04-21-2022', '16:05', 'out');
INSERT INTO SensorActivation VALUES (207, 101, '04-12-2022', '07:12', 'in');
INSERT INTO SensorActivation VALUES (207, 101, '04-12-2022', '16:02', 'out');
INSERT INTO SensorActivation VALUES (207, 101, '04-13-2022', '07:13', 'in');
INSERT INTO SensorActivation VALUES (207, 101, '04-13-2022', '16:03', 'out');
INSERT INTO SensorActivation VALUES (207, 101, '04-14-2022', '07:14', 'in');
INSERT INTO SensorActivation VALUES (207, 101, '04-14-2022', '16:04', 'out');
INSERT INTO SensorActivation VALUES (207, 101, '04-15-2022', '07:15', 'in');
INSERT INTO SensorActivation VALUES (207, 101, '04-15-2022', '16:05', 'out');
INSERT INTO SensorActivation VALUES (207, 102, '04-18-2022', '07:05', 'in');
INSERT INTO SensorActivation VALUES (207, 102, '04-18-2022', '16:02', 'out');
INSERT INTO SensorActivation VALUES (207, 102, '04-19-2022', '07:13', 'in');
INSERT INTO SensorActivation VALUES (207, 102, '04-19-2022', '16:03', 'out');
INSERT INTO SensorActivation VALUES (207, 102, '04-20-2022', '07:14', 'in');
INSERT INTO SensorActivation VALUES (207, 102, '04-20-2022', '16:04', 'out');
INSERT INTO SensorActivation VALUES (207, 102, '04-21-2022', '07:15', 'in');
INSERT INTO SensorActivation VALUES (207, 102, '04-21-2022', '16:05', 'out');
INSERT INTO SensorActivation VALUES (208, 101, '04-12-2022', '07:12', 'in');
INSERT INTO SensorActivation VALUES (208, 101, '04-12-2022', '16:02', 'out');
INSERT INTO SensorActivation VALUES (208, 101, '04-13-2022', '07:13', 'in');
INSERT INTO SensorActivation VALUES (208, 101, '04-13-2022', '16:03', 'out');
INSERT INTO SensorActivation VALUES (208, 101, '04-14-2022', '07:14', 'in');
INSERT INTO SensorActivation VALUES (208, 101, '04-14-2022', '16:04', 'out');
INSERT INTO SensorActivation VALUES (208, 101, '04-15-2022', '07:15', 'in');
INSERT INTO SensorActivation VALUES (208, 101, '04-15-2022', '16:05', 'out');
INSERT INTO SensorActivation VALUES (208, 102, '04-18-2022', '07:05', 'in');
INSERT INTO SensorActivation VALUES (208, 102, '04-18-2022', '16:02', 'out');
INSERT INTO SensorActivation VALUES (208, 102, '04-19-2022', '07:13', 'in');
INSERT INTO SensorActivation VALUES (208, 102, '04-19-2022', '16:03', 'out');
INSERT INTO SensorActivation VALUES (208, 102, '04-20-2022', '07:14', 'in');
INSERT INTO SensorActivation VALUES (208, 102, '04-20-2022', '16:04', 'out');
INSERT INTO SensorActivation VALUES (208, 102, '04-21-2022', '07:15', 'in');
INSERT INTO SensorActivation VALUES (208, 102, '04-21-2022', '16:05', 'out');
INSERT INTO SensorActivation VALUES (209, 101, '04-12-2022', '07:12', 'in');
INSERT INTO SensorActivation VALUES (209, 101, '04-12-2022', '16:02', 'out');
INSERT INTO SensorActivation VALUES (209, 101, '04-13-2022', '07:13', 'in');
INSERT INTO SensorActivation VALUES (209, 101, '04-13-2022', '16:03', 'out');
INSERT INTO SensorActivation VALUES (209, 101, '04-14-2022', '07:14', 'in');
INSERT INTO SensorActivation VALUES (209, 101, '04-14-2022', '16:04', 'out');
INSERT INTO SensorActivation VALUES (209, 101, '04-15-2022', '07:15', 'in');
INSERT INTO SensorActivation VALUES (209, 101, '04-15-2022', '16:05', 'out');
INSERT INTO SensorActivation VALUES (209, 102, '04-18-2022', '07:05', 'in');
INSERT INTO SensorActivation VALUES (209, 102, '04-18-2022', '16:02', 'out');
INSERT INTO SensorActivation VALUES (209, 102, '04-19-2022', '07:13', 'in');
INSERT INTO SensorActivation VALUES (209, 102, '04-19-2022', '16:03', 'out');
INSERT INTO SensorActivation VALUES (209, 102, '04-20-2022', '07:14', 'in');
INSERT INTO SensorActivation VALUES (209, 102, '04-20-2022', '16:04', 'out');
INSERT INTO SensorActivation VALUES (209, 102, '04-21-2022', '07:15', 'in');
INSERT INTO SensorActivation VALUES (209, 102, '04-21-2022', '16:05', 'out');


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
