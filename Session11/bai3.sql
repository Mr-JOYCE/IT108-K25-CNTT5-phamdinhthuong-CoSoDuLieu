USE RikkeiClinicDB;

-- 1) Dữ liệu đầu vào / đầu ra & loại tham số
--
-- Đầu vào:
--   - Tổng chi phí (số tiền gốc trước hỗ trợ/giảm giá): DECIMAL(18,2) — IN
--   - Diện bệnh nhân: chuỗi 'BHYT' | 'VIP' | 'THUONG' — IN VARCHAR
--
-- Đầu ra:
--   - Số tiền cuối cùng phải thu: DECIMAL(18,2) — OUT
--   - Thông báo trạng thái hiển thị: VARCHAR(255) — OUT
--
-- Thủ tục MySQL không “return” nhiều giá trị như hàm; dùng tham số OUT (hoặc
-- INOUT) để trả kết quả cho ứng dụng/thu ngân đọc sau CALL.

-- 2) Giải pháp & các bước thực hiện
--
-- Bước 1: Nếu tổng chi phí < 0 → gán số tiền thu = 0, thông báo lỗi cố định,
--         không áp dụng quy tắc BHYT/VIP/THUONG.
-- Bước 2: Ngược lại, theo diện: BHYT → 20% chi phí; VIP → 90% (giảm 10%);
--         THUONG → 100%; gán thông báo thành công.
-- Bước 3: DROP procedure cũ (nếu có) và CREATE lại để triển khai.

DROP PROCEDURE IF EXISTS CalculateDischargePayment;

DELIMITER //

CREATE PROCEDURE CalculateDischargePayment(
    IN  p_total_cost DECIMAL(18,2),
    IN  p_patient_category VARCHAR(20),
    OUT p_amount_due DECIMAL(18,2),
    OUT p_status_message VARCHAR(255)
)
BEGIN
    DECLARE v_cat VARCHAR(20);

    SET v_cat = UPPER(TRIM(p_patient_category));

    IF p_total_cost < 0 THEN
        SET p_amount_due = 0;
        SET p_status_message = 'Lỗi: Chi phí không hợp lệ';
    ELSE
        IF v_cat = 'BHYT' THEN
            SET p_amount_due = p_total_cost * 0.20;
        ELSEIF v_cat = 'VIP' THEN
            SET p_amount_due = p_total_cost * 0.90;
        ELSE
            SET p_amount_due = p_total_cost;
        END IF;
        SET p_status_message = 'Đã tính toán xong';
    END IF;
END //

DELIMITER ;

-- 3) Kiểm thử: BHYT, VIP, THUONG, và chi phí âm (chặn + thông báo lỗi)

SET @so_tien := NULL, @thong_bao := NULL;

-- Trường hợp BHYT (1.000.000 → đóng 20% = 200.000)
CALL CalculateDischargePayment(1000000.00, 'BHYT', @so_tien, @thong_bao);
SELECT @so_tien AS so_tien_phai_thu, @thong_bao AS thong_bao;

-- Trường hợp VIP (giảm 10% → 1.000.000 × 90% = 900.000)
CALL CalculateDischargePayment(1000000.00, 'VIP', @so_tien, @thong_bao);
SELECT @so_tien AS so_tien_phai_thu, @thong_bao AS thong_bao;

-- Trường hợp THUONG (100%)
CALL CalculateDischargePayment(1000000.00, 'THUONG', @so_tien, @thong_bao);
SELECT @so_tien AS so_tien_phai_thu, @thong_bao AS thong_bao;

-- Trường hợp tổng chi phí âm: không tính, thu 0 + thông báo lỗi
CALL CalculateDischargePayment(-500000.00, 'BHYT', @so_tien, @thong_bao);
SELECT @so_tien AS so_tien_phai_thu, @thong_bao AS thong_bao;
