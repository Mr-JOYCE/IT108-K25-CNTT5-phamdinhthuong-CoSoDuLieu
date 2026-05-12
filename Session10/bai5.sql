DROP VIEW IF EXISTS National_Record_View;

DROP TABLE IF EXISTS Records_South;
DROP TABLE IF EXISTS Records_North;

CREATE TABLE Records_North (
    Record_ID INT PRIMARY KEY,
    Patient_Name VARCHAR(100) NOT NULL,
    Diagnosis TEXT NOT NULL,
    Record_Date DATE NOT NULL
);

CREATE TABLE Records_South (
    Record_ID INT PRIMARY KEY,
    Patient_Name VARCHAR(100) NOT NULL,
    Diagnosis TEXT NOT NULL,
    Record_Date DATE NOT NULL
);

INSERT INTO Records_North (Record_ID, Patient_Name, Diagnosis, Record_Date)
VALUES (1, 'Nguyen Van A', 'Flu', DATE '2026-04-28');

INSERT INTO Records_South (Record_ID, Patient_Name, Diagnosis, Record_Date)
VALUES (1, 'Le Thi B', 'Cold', DATE '2026-04-28');

CREATE VIEW National_Record_View AS
SELECT
    r.Record_ID,
    r.Patient_Name,
    r.Diagnosis,
    r.Record_Date,
    'North' AS Branch_Name
FROM Records_North AS r
UNION ALL
SELECT
    s.Record_ID,
    s.Patient_Name,
    s.Diagnosis,
    s.Record_Date,
    'South' AS Branch_Name
FROM Records_South AS s;

SELECT *
FROM National_Record_View
ORDER BY Branch_Name, Record_ID;

SELECT 'Xung đột ID: Record_ID = 1 có ở cả hai chi nhánh. UNION ALL không loại trùng (khác UNION), nên cả hai bản ghi vẫn hiển thị; cột Branch_Name phân biệt nguồn — không mất dữ liệu. Nếu cần mã duy nhất toàn hệ thống: dùng khóa ghép (Branch_Name, Record_ID), đổi mã theo miền hoặc thêm cột surrogate key chung.' AS ghichu_xuly_xungdot;
