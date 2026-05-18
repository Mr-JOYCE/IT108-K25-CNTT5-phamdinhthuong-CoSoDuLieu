USE RikkeiClinicDB;

-- PHẦN A: THIẾT KẾ KIẾN TRÚC

-- A.1. Flowchart — Luồng EmergencyAdmission (Master) + FindAvailableBed (Sub)
/*
                         ┌─────────────────────────┐
                         │  Tiếp tân: IN patient,  │
                         │  doctor, datetime, dept │
                         └───────────┬─────────────┘
                                     ▼
                         ┌─────────────────────────┐
                         │   START TRANSACTION     │ ◄── Mốc giao dịch (1)
                         └───────────┬─────────────┘
                                     ▼
              ┌──────────────────────────────────────────────┐
              │ 🔴 Chốt 1: Bệnh nhân đã có giường?           │
              │     EXISTS Beds WHERE patient_id = ?         │
              └───────────┬──────────────────┬───────────────┘
                          │ Có               │ Không
                          ▼                  ▼
              ┌───────────────────┐   ┌──────────────────────┐
              │ ROLLBACK          │   │ 🔴 Chốt 2: Khoa     │
              │ OUT: Đang lưu trú │   │     tồn tại?         │
              └───────────────────┘   └──────┬───────┬───────┘
                                             │ Không │ Có
                                             ▼       ▼
                                    ┌────────────┐  ┌─────────────────────────┐
                                    │ ROLLBACK   │  │ CALL FindAvailableBed   │
                                    │ OUT: Khoa  │  │ (Sub — dò giường trống) │
                                    │ không tồn  │  └───────────┬─────────────┘
                                    └────────────┘              ▼
                                              ┌──────────────────────────────────┐
                                              │ 🔴 Chốt 3: p_bed_id IS NULL?     │
                                              │     (Khoa hết giường trống)      │
                                              └──────────┬───────────────┬───────┘
                                                         │ Có          │ Không
                                                         ▼             ▼
                                              ┌────────────────┐  ┌──────────────────┐
                                              │ ROLLBACK       │  │ INSERT           │
                                              │ OUT: Hết giường│  │ Appointments     │
                                              └────────────────┘  └────────┬─────────┘
                                                                           ▼
                                                                ┌──────────────────┐
                                                                │ UPDATE Beds      │
                                                                │ gán patient_id   │
                                                                └────────┬─────────┘
                                                                         ▼
                                                                ┌──────────────────┐
                                                                │ COMMIT           │ ◄── Mốc giao dịch (2)
                                                                │ OUT: Thành công  │
                                                                └──────────────────┘

  EXIT HANDLER FOR SQLEXCEPTION → ROLLBACK → OUT lỗi hệ thống (mọi bước trên)
*/

-- A.2. Thiết kế giao tiếp (Master ↔ Sub)
/*
Đầu vào từ Tiếp tân (Master — IN):
  - p_patient_id        INT
  - p_doctor_id         INT
  - p_appointment_time  DATETIME
  - p_dept_id           INT

Đầu ra cho UI (Master — OUT):
  - p_status_message    VARCHAR(255)
  - p_appointment_id    INT          (0 nếu thất bại)
  - p_bed_id            INT          (0 nếu thất bại)

Sub-procedure FindAvailableBed:
  - IN  p_dept_id       INT          — khoa cần xếp giường
  - OUT p_bed_id        INT          — mã giường trống; NULL = hết giường

Master "hứng" mã giường:
  - Khai báo biến cục bộ v_bed_id INT trong Master.
  - Gọi: CALL FindAvailableBed(p_dept_id, v_bed_id);
  - MySQL truyền OUT của Sub vào biến Master qua tham số thứ hai (không cần INOUT).
  - Master đọc v_bed_id; nếu NULL → ROLLBACK, không INSERT Lịch khám.

Không dùng INOUT cho bed_id vì chiều dữ liệu một chiều: Sub chỉ trả kết quả, Master chỉ nhận.
*/

-- PHẦN B: TRIỂN KHAI

DROP PROCEDURE IF EXISTS EmergencyAdmission;
DROP PROCEDURE IF EXISTS FindAvailableBed;

DELIMITER //

-- Sub-procedure: dò một giường trống trong khoa (khóa hàng khi gọi trong transaction)
CREATE PROCEDURE FindAvailableBed(
    IN p_dept_id INT,
    OUT p_bed_id INT
)
BEGIN
    SET p_bed_id = NULL;

    SELECT bed_id
    INTO p_bed_id
    FROM Beds
    WHERE dept_id = p_dept_id
      AND patient_id IS NULL
    ORDER BY bed_id
    LIMIT 1
    FOR UPDATE;
END //

-- Master-procedure: điều phối nhập viện khẩn cấp (một khối giao dịch)
CREATE PROCEDURE EmergencyAdmission(
    IN p_patient_id INT,
    IN p_doctor_id INT,
    IN p_appointment_time DATETIME,
    IN p_dept_id INT,
    OUT p_status_message VARCHAR(255),
    OUT p_appointment_id INT,
    OUT p_bed_id INT
)
BEGIN
    DECLARE v_bed_id INT DEFAULT NULL;
    DECLARE v_dept_exists INT DEFAULT 0;
    DECLARE v_inpatient INT DEFAULT 0;
    DECLARE v_next_appointment_id INT DEFAULT 0;

    DECLARE EXIT HANDLER FOR SQLEXCEPTION
    BEGIN
        ROLLBACK;
        SET p_appointment_id = 0;
        SET p_bed_id = 0;
        SET p_status_message = 'Lỗi: Hệ thống xử lý thất bại, giao dịch đã hoàn tác';
    END;

    SET p_appointment_id = 0;
    SET p_bed_id = 0;
    SET p_status_message = '';

    START TRANSACTION;

    -- Chốt 1: bệnh nhân đang nội trú (bất kỳ khoa nào)
    SELECT COUNT(*)
    INTO v_inpatient
    FROM Beds
    WHERE patient_id = p_patient_id
    FOR UPDATE;

    IF v_inpatient > 0 THEN
        ROLLBACK;
        SET p_status_message = 'Từ chối: Bệnh nhân đang lưu trú';
    ELSE
        -- Chốt 2: khoa có tồn tại
        SELECT COUNT(*)
        INTO v_dept_exists
        FROM Departments
        WHERE dept_id = p_dept_id;

        IF v_dept_exists = 0 THEN
            ROLLBACK;
            SET p_status_message = 'Từ chối: Khoa không tồn tại';
        ELSE
            -- Ủy quyền dò giường cho Sub-procedure
            CALL FindAvailableBed(p_dept_id, v_bed_id);

            -- Chốt 3: hết giường trống trong khoa yêu cầu
            IF v_bed_id IS NULL THEN
                ROLLBACK;
                SET p_status_message = 'Từ chối: Khoa hiện đã hết giường';
            ELSE
                SELECT COALESCE(MAX(appointment_id), 0) + 1
                INTO v_next_appointment_id
                FROM Appointments
                FOR UPDATE;

                INSERT INTO Appointments (
                    appointment_id,
                    patient_id,
                    doctor_id,
                    appointment_date,
                    status
                ) VALUES (
                    v_next_appointment_id,
                    p_patient_id,
                    p_doctor_id,
                    p_appointment_time,
                    'Pending'
                );

                UPDATE Beds
                SET patient_id = p_patient_id
                WHERE bed_id = v_bed_id;

                COMMIT;

                SET p_appointment_id = v_next_appointment_id;
                SET p_bed_id = v_bed_id;
                SET p_status_message = CONCAT(
                    'Nhập viện thành công. Lịch #',
                    v_next_appointment_id,
                    ', Giường #',
                    v_bed_id
                );
            END IF;
        END IF;
    END IF;
END //

DELIMITER ;

-- KIỂM THỬ — Chuẩn bị dữ liệu (trạng thái gốc bai1.sql)

UPDATE Beds SET patient_id = NULL WHERE bed_id IN (101, 201, 301);
UPDATE Beds SET patient_id = 1 WHERE bed_id = 101;
UPDATE Beds SET patient_id = 2 WHERE bed_id = 301;

DELETE FROM Appointments WHERE appointment_id > 106;

SELECT bed_id, dept_id, patient_id FROM Beds ORDER BY bed_id;
SELECT appointment_id, patient_id, doctor_id, status FROM Appointments;

-- 4 KỊCH BẢN NGHIỆM THU

-- (1) Nhập viện thành công — BN 3 (chưa có giường), Khoa Nội (2), giường 201 trống
CALL EmergencyAdmission(3, 101, '2026-05-19 14:00:00', 2, @msg, @appt_id, @bed_id);
SELECT @msg AS thong_bao, @appt_id AS ma_lich, @bed_id AS ma_giuong;
SELECT appointment_id, patient_id, doctor_id, status FROM Appointments WHERE patient_id = 3;
SELECT bed_id, dept_id, patient_id FROM Beds WHERE bed_id = 201;

-- Reset cho các test tiếp theo
UPDATE Beds SET patient_id = NULL WHERE bed_id = 201;
DELETE FROM Appointments WHERE patient_id = 3 AND appointment_id > 106;

-- (2) Bẫy hết giường trống — BN 3, Khoa Ngoại (1): chỉ giường 101, đã có BN 1
CALL EmergencyAdmission(3, 101, '2026-05-19 15:00:00', 1, @msg, @appt_id, @bed_id);
SELECT @msg AS thong_bao, @appt_id AS ma_lich, @bed_id AS ma_giuong;
SELECT COUNT(*) AS so_lich_moi_bn3 FROM Appointments
WHERE patient_id = 3 AND appointment_date = '2026-05-19 15:00:00';

-- (3) Bẫy bệnh nhân đang nội trú — BN 1 đã nằm giường 101, xin nhập Khoa Nội (2)
CALL EmergencyAdmission(1, 102, '2026-05-19 16:00:00', 2, @msg, @appt_id, @bed_id);
SELECT @msg AS thong_bao, @appt_id AS ma_lich, @bed_id AS ma_giuong;
SELECT bed_id, patient_id FROM Beds WHERE patient_id = 1;

-- (4) Chuyển vào khoa không tồn tại — dept_id 999
CALL EmergencyAdmission(3, 101, '2026-05-19 17:00:00', 999, @msg, @appt_id, @bed_id);
SELECT @msg AS thong_bao, @appt_id AS ma_lich, @bed_id AS ma_giuong;
