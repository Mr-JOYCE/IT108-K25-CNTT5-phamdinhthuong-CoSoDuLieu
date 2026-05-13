CREATE DATABASE IF NOT EXISTS RikkeiClinicDB;
USE RikkeiClinicDB;

-- Khởi tạo nhanh: Patients (tối thiểu cho FK), Medicines, Patient_Invoices

DROP TABLE IF EXISTS Patient_Invoices;
DROP TABLE IF EXISTS Medicines;
DROP TABLE IF EXISTS Patients;

CREATE TABLE Patients (
    patient_id INT PRIMARY KEY,
    full_name VARCHAR(100) NOT NULL
);

CREATE TABLE Medicines (
    medicine_id INT PRIMARY KEY,
    name VARCHAR(100) NOT NULL,
    price DECIMAL(18,2) NOT NULL,
    stock INT NOT NULL DEFAULT 0
);

CREATE TABLE Patient_Invoices (
    patient_id INT PRIMARY KEY,
    total_due DECIMAL(18,2) NOT NULL DEFAULT 0,
    last_updated DATETIME DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    FOREIGN KEY (patient_id) REFERENCES Patients(patient_id)
);

INSERT INTO Patients (patient_id, full_name) VALUES
(1, 'Nguyen Van An');

INSERT INTO Medicines (medicine_id, name, price, stock) VALUES
(1, 'Amoxicillin 500mg', 15000.00, 100),
(2, 'Panadol Extra', 5000.00, 5);

INSERT INTO Patient_Invoices (patient_id, total_due) VALUES
(1, 100000.00);

-- PHẦN A: PHÂN TÍCH & THIẾT KẾ
--
-- 1) Phân tích I/O
--
--    Đầu vào (IN):
--      - p_patient_id      INT           Mã bệnh nhân
--      - p_medicine_id     INT           Mã thuốc
--      - p_quantity        INT           Số lượng kê
--      - p_discount_code   VARCHAR(...)  Mã giảm giá (có thể NULL hoặc rác)
--
--    Đầu ra — thông báo trạng thái: dùng tham số OUT (ví dụ p_status_message VARCHAR)
--    Vì sao OUT (không dùng INOUT cho chuỗi trạng thái): thủ tục chỉ cần "ghi kết quả"
--    một chiều cho Backend đọc sau CALL; không cần đọc giá trị message trước khi gọi.
--
-- 2) Luồng xử lý & biến cục bộ
--
--    - START TRANSACTION
--    - SELECT price, stock INTO biến cục bộ v_price, v_stock FROM Medicines ... FOR UPDATE
--      (khóa dòng thuốc tránh race khi trừ tồn)
--    - Nếu v_stock < p_quantity → ROLLBACK, OUT = "Thất bại: Kho không đủ thuốc"
--    - Nếu p_quantity <= 0 → ROLLBACK, OUT = "Thất bại: Số lượng không hợp lệ"
--      (chặn sai lệch tồn kho do số âm / 0 — xem ghi chú cuối file)
--    - v_subtotal = p_quantity * v_price  (biến cục bộ DECIMAL)
--    - Nếu TRIM/UPPER(mã) = 'NV-RIKKEI' → v_final = v_subtotal * 0.5; ngược lại v_final = v_subtotal
--      (mã NULL, rỗng, hoặc mã rác → giá gốc, không crash)
--    - UPDATE Medicines SET stock = stock - p_quantity WHERE medicine_id = ...
--    - UPDATE Patient_Invoices SET total_due = total_due + v_final WHERE patient_id = ...
--    - COMMIT, OUT = "Thành công: Đã xử lý đơn thuốc"
--
-- 3) Ghi chú rủi ro (code cũ không validate)
--    Chỉ kiểm tra tồn >= số lượng mà không chặn số lượng <= 0 thì lệnh UPDATE
--    stock = stock - p_quantity có thể làm tăng tồn (số âm) hoặc không nghiệp vụ (0).

DROP PROCEDURE IF EXISTS ProcessPrescription;

DELIMITER //

CREATE PROCEDURE ProcessPrescription(
    IN  p_patient_id INT,
    IN  p_medicine_id INT,
    IN  p_quantity INT,
    IN  p_discount_code VARCHAR(50),
    OUT p_status_message VARCHAR(255)
)
BEGIN
    DECLARE v_unit_price DECIMAL(18,2) DEFAULT 0;
    DECLARE v_stock INT DEFAULT 0;
    DECLARE v_subtotal DECIMAL(18,2) DEFAULT 0;
    DECLARE v_final DECIMAL(18,2) DEFAULT 0;
    DECLARE v_code VARCHAR(50);
    DECLARE v_invoice_exists INT DEFAULT 0;
    DECLARE v_med_exists INT DEFAULT 0;

    SET p_status_message = NULL;

    START TRANSACTION;

    SELECT COUNT(*) INTO v_invoice_exists
    FROM Patient_Invoices
    WHERE patient_id = p_patient_id;

    IF v_invoice_exists = 0 THEN
        ROLLBACK;
        SET p_status_message = 'Thất bại: Không tìm thấy hồ sơ công nợ bệnh nhân.';
    ELSEIF p_quantity <= 0 THEN
        ROLLBACK;
        SET p_status_message = 'Thất bại: Số lượng không hợp lệ';
    ELSE
        SELECT COUNT(*) INTO v_med_exists
        FROM Medicines m
        WHERE m.medicine_id = p_medicine_id;

        IF v_med_exists = 0 THEN
            ROLLBACK;
            SET p_status_message = 'Thất bại: Không tìm thấy thuốc.';
        ELSE
            SELECT m.price, m.stock INTO v_unit_price, v_stock
            FROM Medicines m
            WHERE m.medicine_id = p_medicine_id
            LIMIT 1
            FOR UPDATE;

            IF v_stock < p_quantity THEN
                ROLLBACK;
                SET p_status_message = 'Thất bại: Kho không đủ thuốc';
            ELSE
                SET v_subtotal = p_quantity * v_unit_price;

                SET v_code = UPPER(TRIM(IFNULL(p_discount_code, '')));

                IF v_code = 'NV-RIKKEI' THEN
                    SET v_final = v_subtotal * 0.5;
                ELSE
                    SET v_final = v_subtotal;
                END IF;

                UPDATE Medicines
                SET stock = stock - p_quantity
                WHERE medicine_id = p_medicine_id;

                UPDATE Patient_Invoices
                SET total_due = total_due + v_final
                WHERE patient_id = p_patient_id;

                COMMIT;
                SET p_status_message = 'Thành công: Đã xử lý đơn thuốc';
            END IF;
        END IF;
    END IF;
END //

DELIMITER ;

-- PHẦN B: KIỂM THỬ (reset DB ở trên nếu cần chạy lại từ đầu)
SET @msg := NULL;

-- (1) Kê đơn bình thường, không mã giảm giá (NULL): 2 * 15000 = 30000 → cộng vào total_due
CALL ProcessPrescription(1, 1, 2, NULL, @msg);
SELECT @msg AS status_message;

-- (2) Mã NV-RIKKEI: 1 * 15000 * 50% = 7500
CALL ProcessPrescription(1, 1, 1, 'NV-RIKKEI', @msg);
SELECT @msg AS status_message;

-- (3) Bẫy Out of stock: thuốc id=2 chỉ còn 5, kê 10 → không trừ kho, không cộng nợ
CALL ProcessPrescription(1, 2, 10, NULL, @msg);
SELECT @msg AS status_message;

-- Kiểm tra nhanh tồn kho & nợ sau 3 lệnh trên:
SELECT medicine_id, stock FROM Medicines ORDER BY medicine_id;
SELECT patient_id, total_due FROM Patient_Invoices WHERE patient_id = 1;
