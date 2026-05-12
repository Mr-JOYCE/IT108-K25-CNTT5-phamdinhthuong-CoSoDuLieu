DROP VIEW IF EXISTS ER_Dashboard_View;

DROP TABLE IF EXISTS Vitals_Logs;
DROP TABLE IF EXISTS Patients;

CREATE TABLE Patients (
    Patient_ID CHAR(5) PRIMARY KEY,
    Full_Name VARCHAR(100) NOT NULL,
    Admission_Time DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP
) ENGINE=InnoDB;

CREATE TABLE Vitals_Logs (
    Log_ID INT AUTO_INCREMENT PRIMARY KEY,
    Patient_ID CHAR(5) NOT NULL,
    Heart_Rate INT NOT NULL,
    Blood_Pressure VARCHAR(25) NOT NULL,
    Record_Time DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT fk_vitals_logs_patient
        FOREIGN KEY (Patient_ID) REFERENCES Patients (Patient_ID)
        ON DELETE CASCADE
        ON UPDATE CASCADE,
    CONSTRAINT chk_vitals_logs_heart_positive
        CHECK (Heart_Rate > 0)
) ENGINE=InnoDB;

CREATE INDEX ix_vitals_logs_patient_record_time ON Vitals_Logs (Patient_ID, Record_Time);

CREATE VIEW ER_Dashboard_View AS
SELECT
    p.Patient_ID,
    p.Full_Name,
    p.Admission_Time,
    COALESCE(CAST(vl.Heart_Rate AS CHAR), 'Pending') AS Heart_Rate_Status,
    COALESCE(vl.Blood_Pressure, 'Pending') AS Blood_Pressure_Status,
    vl.Record_Time AS Last_Record_Time,
    CASE
        WHEN vl.Heart_Rate IS NULL THEN 'Pending'
        WHEN vl.Heart_Rate > 120 OR vl.Heart_Rate < 50 THEN 'CRITICAL'
        ELSE 'STABLE'
    END AS Urgency_Level
FROM Patients AS p
LEFT JOIN Vitals_Logs AS vl
    ON vl.Patient_ID = p.Patient_ID
   AND vl.Record_Time = (
        SELECT MAX(v2.Record_Time)
        FROM Vitals_Logs AS v2
        WHERE v2.Patient_ID = p.Patient_ID
    );

INSERT INTO Patients (Patient_ID, Full_Name, Admission_Time) VALUES
    ('BN001', 'Tran Van Cuong', '2026-05-01 09:15:22'),
    ('BN002', 'Pham Thi Dao', '2026-05-12 11:05:00'),
    ('BN003', 'Nguyen Minh Khoi', '2026-05-12 07:42:31');

INSERT INTO Vitals_Logs (Patient_ID, Heart_Rate, Blood_Pressure, Record_Time) VALUES
    ('BN001', 98, '118/76', '2026-05-12 10:00:15'),
    ('BN001', 105, '120/79', '2026-05-12 10:12:40'),
    ('BN003', 128, '140/92', '2026-05-12 10:20:03');

SELECT * FROM ER_Dashboard_View ORDER BY Patient_ID;

EXPLAIN
SELECT Patient_ID,
       Heart_Rate,
       Record_Time
FROM Vitals_Logs
WHERE Patient_ID = 'BN001'
  AND Record_Time = (
      SELECT MAX(vi.Record_Time)
      FROM Vitals_Logs AS vi
      WHERE vi.Patient_ID = 'BN001'
  );

SELECT 'Thao tác 4: bỏ dấu -- ở một trong các lệnh dưới và chạy riêng. MySQL từ chối INSERT/UPDATE vì VIEW có JOIN và cột được tính (không SIMPLE updatable).' AS thao_tac_4_hd;