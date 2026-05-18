USE RikkeiClinicDB;

-- 1. XÁC ĐỊNH ĐẦU VÀO / ĐẦU RA & LOẠI THAM SỐ
/*
Đầu vào:
  - Mã bệnh nhân   (patient_id)  : INT
  - Mã thuốc       (medicine_id) : INT
  - Số lượng cấp   (quantity)    : INT

Đầu ra:
  - Thông báo trạng thái hiển thị trên màn hình : VARCHAR

Đề xuất tham số Stored Procedure:
  - IN  p_patient_id, p_medicine_id, p_quantity  : nhận dữ liệu từ nhân viên
  - OUT p_status_message                         : trả chuỗi thông báo cho UI
*/

-- 2. GIẢI PHÁP & CÁC BƯỚC THỰC HIỆN (KIỂM SOÁT GIAO DỊCH)

/*
Bước 1: START TRANSACTION — gom "Kho" và "Công nợ" thành một khối giao dịch.
Bước 2: Đọc tồn kho và đơn giá thuốc (có khóa FOR UPDATE trong transaction).
Bước 3: Nếu số lượng yêu cầu > tồn kho → ROLLBACK, gán OUT thông báo lỗi, kết thúc.
Bước 4: Trừ kho (Medicines.stock) và cộng công nợ (quantity × price vào Patient_Invoices).
Bước 5: COMMIT và gán OUT "Đã cấp phát thành công".
Bước 6: EXIT HANDLER FOR SQLEXCEPTION → ROLLBACK khi lỗi hệ thống bất ngờ.
*/


-- 3. TRIỂN KHAI MÃ NGUỒN

DROP PROCEDURE IF EXISTS DispenseMedicine;

DELIMITER //

CREATE PROCEDURE DispenseMedicine(
    IN p_patient_id INT,
    IN p_medicine_id INT,
    IN p_quantity INT,
    OUT p_status_message VARCHAR(255)
)
BEGIN
    DECLARE v_stock INT DEFAULT 0;
    DECLARE v_price DECIMAL(18,2) DEFAULT 0;
    DECLARE v_line_total DECIMAL(18,2) DEFAULT 0;

    DECLARE EXIT HANDLER FOR SQLEXCEPTION
    BEGIN
        ROLLBACK;
        SET p_status_message = 'Lỗi: Hệ thống xử lý thất bại';
    END;

    START TRANSACTION;

    SELECT stock, price
    INTO v_stock, v_price
    FROM Medicines
    WHERE medicine_id = p_medicine_id
    FOR UPDATE;

    IF v_stock IS NULL THEN
        ROLLBACK;
        SET p_status_message = 'Lỗi: Không tìm thấy thuốc';
    ELSEIF p_quantity > v_stock THEN
        ROLLBACK;
        SET p_status_message = 'Lỗi: Số lượng tồn kho không đủ';
    ELSE
        SET v_line_total = p_quantity * v_price;

        UPDATE Medicines
        SET stock = stock - p_quantity
        WHERE medicine_id = p_medicine_id;

        UPDATE Patient_Invoices
        SET total_due = total_due + v_line_total,
            last_updated = CURRENT_TIMESTAMP
        WHERE patient_id = p_patient_id;

        COMMIT;
        SET p_status_message = 'Đã cấp phát thành công';
    END IF;
END //

DELIMITER ;

-- 4. KIỂM THỬ

-- Kiểm tra dữ liệu gốc (thuốc 1: tồn 100; thuốc 2 Panadol: tồn 5)
SELECT medicine_id, name, stock, price FROM Medicines WHERE medicine_id IN (1, 2);
SELECT patient_id, total_due FROM Patient_Invoices WHERE patient_id = 1;

-- Test 1: Cấp phát hợp lệ — BN 1, thuốc 1 (Amoxicillin), số lượng 2
CALL DispenseMedicine(1, 1, 2, @status_msg);
SELECT @status_msg AS thong_bao;

SELECT medicine_id, stock FROM Medicines WHERE medicine_id = 1;
SELECT patient_id, total_due FROM Patient_Invoices WHERE patient_id = 1;

-- Test 2: Vượt tồn kho — BN 1, thuốc 2 (Panadol, tồn 5), nhập 10 → phải chặn & báo lỗi
CALL DispenseMedicine(1, 2, 10, @status_msg);
SELECT @status_msg AS thong_bao;

SELECT medicine_id, stock FROM Medicines WHERE medicine_id = 2;
SELECT patient_id, total_due FROM Patient_Invoices WHERE patient_id = 1;
