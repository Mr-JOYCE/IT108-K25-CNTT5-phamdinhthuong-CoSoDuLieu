CREATE DATABASE Hospital;

USE Hospital;

CREATE TABLE Patients (
    Patient_ID INT PRIMARY KEY,
    Full_Name VARCHAR(100),
    Age INT,
    Room_Number INT,
    HIV_Status VARCHAR(50),
    Mental_Health_History VARCHAR(255)
);

INSERT INTO Patients (Patient_ID, Full_Name, Age, Room_Number, HIV_Status, Mental_Health_History)
VALUES
    (1, 'Minh Thu', 30, 101, 'Negative', 'None'),
    (2, 'Hồng Vân', 40, 102, 'Positive', 'Anxiety'),
    (3, 'Cao Cường', 25, 103, 'Negative', 'None');

DROP VIEW IF EXISTS Reception_Patient_View;
GO

CREATE VIEW Reception_Patient_View AS
SELECT
    Patient_ID,
    Full_Name,
    Age,
    Room_Number
FROM Patients
WHERE Age >= 0
WITH CHECK OPTION;
GO

SELECT * FROM Reception_Patient_View;

UPDATE Reception_Patient_View
SET Age = 31
WHERE Patient_ID = 1;

SELECT * FROM Reception_Patient_View WHERE Patient_ID = 1;

UPDATE Reception_Patient_View
SET Age = -5
WHERE Patient_ID = 1;