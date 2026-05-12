DROP TABLE IF EXISTS Patients;
DROP PROCEDURE IF EXISTS SeedPatients;
DROP PROCEDURE IF EXISTS BenchInsertPatients;

CREATE TABLE Patients (
    Patient_ID INT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
    Full_Name VARCHAR(150) NOT NULL,
    Phone VARCHAR(32) NOT NULL,
    Age INT NOT NULL,
    Address VARCHAR(255) NOT NULL
) ENGINE=InnoDB;

DELIMITER //
CREATE PROCEDURE SeedPatients()
BEGIN
    DECLARE i INT DEFAULT 1;
    WHILE i <= 500000 DO
        INSERT INTO Patients (Full_Name, Phone, Age, Address)
        VALUES (CONCAT('Patient ', i), CONCAT('090', i), FLOOR(RAND() * 100), 'Ho Chi Minh City');
        SET i = i + 1;
    END WHILE;
END //
DELIMITER ;

CALL SeedPatients();

SET @bench_phone = CONCAT('090', 388888);

SELECT '--- SELECT trước khi tạo index (ghi lại elapsed & các cột type/key/rows/Extra của EXPLAIN)' AS step;
SELECT 'Query plan (chưa có index trên Phone):' AS info;
EXPLAIN
SELECT Patient_ID, Full_Name, Phone, Age, Address
FROM Patients
WHERE Phone = @bench_phone
LIMIT 1;

SET @ts_start = NOW(6);
SELECT Patient_ID, Full_Name, Phone, Age, Address
FROM Patients
WHERE Phone = @bench_phone
LIMIT 1;
SELECT TIMESTAMPDIFF(MICROSECOND, @ts_start, NOW(6)) / 1000000.0 AS select_before_index_sec;

CREATE INDEX idx_patients_phone ON Patients (Phone);
ANALYZE TABLE Patients;

SELECT '--- SELECT sau khi tạo index' AS step;
SELECT 'Query plan (có index trên Phone):' AS info;
EXPLAIN
SELECT Patient_ID, Full_Name, Phone, Age, Address
FROM Patients
WHERE Phone = @bench_phone
LIMIT 1;

SET @ts_start = NOW(6);
SELECT Patient_ID, Full_Name, Phone, Age, Address
FROM Patients
WHERE Phone = @bench_phone
LIMIT 1;
SELECT TIMESTAMPDIFF(MICROSECOND, @ts_start, NOW(6)) / 1000000.0 AS select_after_index_sec;

DELIMITER //
CREATE PROCEDURE BenchInsertPatients(IN p_run_id BIGINT)
BEGIN
    DECLARE k INT DEFAULT 1;
    WHILE k <= 1000 DO
        INSERT INTO Patients (Full_Name, Phone, Age, Address)
        VALUES (
            CONCAT('Bench-', p_run_id, '-', k),
            CONCAT('080', CAST(p_run_id AS CHAR), LPAD(k, 7, '0')),
            FLOOR(RAND() * 100),
            'Ho Chi Minh City'
        );
        SET k = k + 1;
    END WHILE;
END //
DELIMITER ;

SELECT '--- Ghi có index (PHONE đã được đánh chỉ mục)' AS step;
SET @run_a = UNIX_TIMESTAMP();
SET @ts_start = NOW(6);
CALL BenchInsertPatients(@run_a);
SELECT TIMESTAMPDIFF(MICROSECOND, @ts_start, NOW(6)) / 1000000.0 AS insert_1000_with_index_sec;

DROP INDEX idx_patients_phone ON Patients;

SELECT '--- Ghi không index (đã DROP INDEX)' AS step;
SET @run_b = UNIX_TIMESTAMP() + 1000000;
SET @ts_start = NOW(6);
CALL BenchInsertPatients(@run_b);
SELECT TIMESTAMPDIFF(MICROSECOND, @ts_start, NOW(6)) / 1000000.0 AS insert_1000_without_index_sec;

CREATE INDEX idx_patients_phone ON Patients (Phone);
ANALYZE TABLE Patients;

SELECT '----- Báo cáo ngắn (nhận xét)' AS section;
SELECT
    '- Index Phone giúp truy vấn WHERE Phone=? chuyển từ quét full table sang tra cực nhanh trên chỉ mục (quan sát chi phí và số hàng trong EXPLAIN).' AS read_side,
    '- Mỗi INSERT phải cập nhật thêm chỉ mục b-tree nên INSERT 1000 lần thường tốn thời gian hơn khi không có chỉ mục trên Phone.' AS write_side,
    '- Đánh đổi: tăng tốc đọc theo số điện thoại, đổi lại một phần chi phí ghi và không gian đĩa cho chỉ mục.' AS tradeoff;
