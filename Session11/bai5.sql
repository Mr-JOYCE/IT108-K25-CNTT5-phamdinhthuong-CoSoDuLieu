USE RikkeiClinicDB;

-- Cột phục vụ bẫy "đã xuất viện" (hồ sơ Completed). Thêm cột chỉ khi chưa có (chạy lại file an toàn).
SET @col_exists := (
    SELECT COUNT(*) FROM INFORMATION_SCHEMA.COLUMNS
    WHERE TABLE_SCHEMA = DATABASE()
      AND TABLE_NAME = 'Patients'
      AND COLUMN_NAME = 'medical_record_status'
);
SET @ddl := IF(@col_exists = 0,
    'ALTER TABLE Patients ADD COLUMN medical_record_status VARCHAR(20) NOT NULL DEFAULT ''Active'' COMMENT ''Active | Completed''',
    'SELECT 1');
PREPARE _stmt_add_col FROM @ddl;
EXECUTE _stmt_add_col;
DEALLOCATE PREPARE _stmt_add_col;

UPDATE Patients SET medical_record_status = 'Active' WHERE patient_id IN (1, 2);
UPDATE Patients SET medical_record_status = 'Completed' WHERE patient_id = 3;

-- PHẦN A: BẢN VẼ THIẾT KẾ KIẾN TRÚC
--
-- 1) Flowchart (Mermaid — dán vào viewer Mermaid hoặc Markdown preview)
--
--    flowchart TD
--      S([START: TransferPatientBed]) --> V1{🔴 Patient exists<br/>AND record ≠ Completed?}
--      V1 -->|No| R1[ROLLBACK + lỗi xuất viện]
--      V1 -->|Yes| V2{🔴 Target Dept_ID<br/>exists in Departments?}
--      V2 -->|No| R2[ROLLBACK + mã khoa không tồn tại]
--      V2 -->|Yes| F[CALL FindEmptyBed<br/>OUT bed_id]
--      F --> V3{🔴 bed_id NOT NULL?}
--      V3 -->|No| R3[ROLLBACK — KHÔNG giải phóng giường cũ<br/>Từ chối: Khoa ... hết giường]
--      V3 -->|Yes| U[UPDATE giường cũ NULL<br/>UPDATE giường mới = patient]
--      U --> C([COMMIT + success])
--
--    Chốt kiểm tra (đánh dấu đỏ 🔴 trong sơ đồ trên): (1) hồ sơ Completed, (2) khoa không tồn tại,
--    (3) không còn giường trống — phải ROLLBACK trước khi đụng giường cũ.
--
-- 2) Giao tiếp Master ↔ Sub (FindEmptyBed)
--
--    Procedure phụ khai báo: IN p_target_dept_id INT, OUT p_free_bed_id INT
--    Procedure Master DECLARE v_bed INT; rồi CALL FindEmptyBed(p_target_dept_id, v_bed);
--    Tham số OUT của procedure con được "nối" vào biến cục bộ của Master — không cần INOUT
--    trên Master; INOUT chỉ hữu ích nếu vừa truyền vào vừa đọc lại cùng một ô nhớ (không bắt buộc ở đây).

DROP PROCEDURE IF EXISTS TransferPatientBed;
DROP PROCEDURE IF EXISTS FindEmptyBed;

DELIMITER //

-- Sub: scan one free bed in department, lock row (same transaction as caller)
CREATE PROCEDURE FindEmptyBed(IN p_dept_id INT, OUT p_free_bed_id INT)
BEGIN
    DECLARE v_free_count INT DEFAULT 0;

    SET p_free_bed_id = NULL;

    SELECT COUNT(*) INTO v_free_count
    FROM Beds
    WHERE dept_id = p_dept_id
      AND patient_id IS NULL;

    IF v_free_count > 0 THEN
        SELECT bed_id INTO p_free_bed_id
        FROM Beds
        WHERE dept_id = p_dept_id
          AND patient_id IS NULL
        ORDER BY bed_id ASC
        LIMIT 1
        FOR UPDATE;
    END IF;
END //

-- Master: validate → reserve bed via sub → reassign
CREATE PROCEDURE TransferPatientBed(
    IN  p_patient_id INT,
    IN  p_target_dept_id INT,
    OUT p_new_bed_id INT,
    OUT p_status_message VARCHAR(255)
)
BEGIN
    DECLARE v_new_bed INT DEFAULT NULL;
    DECLARE v_old_bed INT DEFAULT NULL;
    DECLARE v_record_status VARCHAR(20);
    DECLARE v_patient_exists INT DEFAULT 0;
    DECLARE v_dept_exists INT DEFAULT 0;
    DECLARE v_dept_name VARCHAR(100) DEFAULT NULL;

    SET p_new_bed_id = NULL;
    SET p_status_message = NULL;

    START TRANSACTION;

    SELECT COUNT(*) INTO v_patient_exists
    FROM Patients
    WHERE patient_id = p_patient_id;

    IF v_patient_exists = 0 THEN
        ROLLBACK;
        SET p_new_bed_id = NULL;
        SET p_status_message = 'Lỗi: Không tìm thấy bệnh nhân.';
    ELSE
        SELECT medical_record_status INTO v_record_status
        FROM Patients
        WHERE patient_id = p_patient_id
        LIMIT 1;

        IF v_record_status = 'Completed' THEN
            ROLLBACK;
            SET p_new_bed_id = NULL;
            SET p_status_message = 'Lỗi: Bệnh nhân đã xuất viện, không thể chuyển giường.';
        ELSE
            SELECT COUNT(*) INTO v_dept_exists
            FROM Departments
            WHERE dept_id = p_target_dept_id;

            IF v_dept_exists = 0 THEN
                ROLLBACK;
                SET p_new_bed_id = NULL;
                SET p_status_message = 'Lỗi: Mã khoa không tồn tại.';
            ELSE
                CALL FindEmptyBed(p_target_dept_id, v_new_bed);

                IF v_new_bed IS NULL THEN
                    SELECT dept_name INTO v_dept_name
                    FROM Departments
                    WHERE dept_id = p_target_dept_id
                    LIMIT 1;

                    ROLLBACK;
                    SET p_new_bed_id = NULL;
                    SET p_status_message = CONCAT('Từ chối: Khoa ', IFNULL(v_dept_name, ''), ' đã hết giường');
                ELSE
                    SELECT MAX(bed_id) INTO v_old_bed
                    FROM Beds
                    WHERE patient_id = p_patient_id
                    FOR UPDATE;

                    IF v_old_bed IS NOT NULL THEN
                        UPDATE Beds SET patient_id = NULL WHERE bed_id = v_old_bed;
                    END IF;

                    UPDATE Beds SET patient_id = p_patient_id WHERE bed_id = v_new_bed;

                    COMMIT;
                    SET p_new_bed_id = v_new_bed;
                    SET p_status_message = 'Đã chuyển giường thành công.';
                END IF;
            END IF;
        END IF;
    END IF;
END //

DELIMITER ;

-- PHẦN B: KIỂM THỬ (gợi ý chạy lại bai1.sql + phần ALTER/UPDATE đầu file để reset)
SET @nb := NULL, @sm := NULL;

-- (4) Khoa không tồn tại
CALL TransferPatientBed(1, 99, @nb, @sm);
SELECT @nb AS new_bed_id, @sm AS status_message;

-- (3) Bệnh nhân đã xuất viện (patient_id = 3, hồ sơ Completed)
CALL TransferPatientBed(3, 2, @nb, @sm);
SELECT @nb AS new_bed_id, @sm AS status_message;

-- (2) Khoa đích hết giường trống (Khoa ICU = 3 chỉ có giường 301 đang có BN 2)
CALL TransferPatientBed(1, 3, @nb, @sm);
SELECT @nb AS new_bed_id, @sm AS status_message;

-- (1) Chuyển khoa thành công (BN 1 từ Khoa 1 → Khoa 2, giường trống 201)
CALL TransferPatientBed(1, 2, @nb, @sm);
SELECT @nb AS new_bed_id, @sm AS status_message;
