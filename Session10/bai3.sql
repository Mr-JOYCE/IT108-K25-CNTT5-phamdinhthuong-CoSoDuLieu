DROP VIEW IF EXISTS Department_Revenue_View;
DROP TABLE IF EXISTS Invoices;
DROP TABLE IF EXISTS Patients;
DROP TABLE IF EXISTS Departments;

CREATE TABLE Departments (
    Dept_ID INT PRIMARY KEY,
    Dept_Name VARCHAR(100) NOT NULL
);

CREATE TABLE Patients (
    Patient_ID INT PRIMARY KEY,
    Full_Name VARCHAR(100) NOT NULL
);

CREATE TABLE Invoices (
    Invoice_ID INT PRIMARY KEY,
    Patient_ID INT NOT NULL,
    Dept_ID INT NOT NULL,
    Amount DECIMAL(10, 2) NOT NULL
);

INSERT INTO Departments (Dept_ID, Dept_Name) VALUES
    (1, 'Nội'),
    (2, 'Ngoại');

INSERT INTO Patients (Patient_ID, Full_Name) VALUES
    (1, 'Bệnh nhân A'),
    (2, 'Bệnh nhân B'),
    (3, 'Bệnh nhân C');

INSERT INTO Invoices (Invoice_ID, Patient_ID, Dept_ID, Amount) VALUES
    (101, 1, 1, 500.00),
    (102, 2, 1, 300.00),
    (103, 3, 2, 1000.00);

CREATE VIEW Department_Revenue_View AS
SELECT
    d.Dept_Name AS Ten_Khoa,
    COUNT(DISTINCT p.Patient_ID) AS Tong_So_Benh_Nhan,
    SUM(i.Amount) AS Tong_Doanh_Thu
FROM Departments AS d
INNER JOIN Invoices AS i ON i.Dept_ID = d.Dept_ID
INNER JOIN Patients AS p ON p.Patient_ID = i.Patient_ID
GROUP BY d.Dept_ID, d.Dept_Name;

SELECT * FROM Department_Revenue_View ORDER BY Ten_Khoa;

UPDATE Department_Revenue_View
SET Tong_Doanh_Thu = 99999.99
WHERE Ten_Khoa = 'Nội';
