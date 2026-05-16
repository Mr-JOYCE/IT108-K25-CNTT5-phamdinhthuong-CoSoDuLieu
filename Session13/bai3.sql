USE RikkeiClinicDB;

-- PHẦN 1 — Phân tích & giải pháp (tóm tắt)

/*
Cấu trúc đề xuất bảng Price_Changes_Log:
  - log_id           : khóa surrogate, AUTO_INCREMENT (định danh dòng nhật ký).
  - medicine_id      : mã thuốc (FK → Medicines).
  - old_price        : giá trước khi cập nhật (OLD.price).
  - new_price        : giá sau khi cập nhật (NEW.price).
  - change_status    : 'TĂNG GIÁ' | 'GIẢM GIÁ' (theo quy tắc nghiệp vụ).
  - difference_amount: chênh lệch dương (NEW−OLD nếu tăng, OLD−NEW nếu giảm).
  - changed_at       : thời điểm ghi log (mặc định CURRENT_TIMESTAMP).

Thời điểm trigger: BEFORE UPDATE ON Medicines.

Luồng logic (OLD / NEW):
  1) Luôn đọc NEW.price trước: nếu NEW.price <= 0 → SIGNAL, chặn toàn bộ UPDATE
     (không tính chênh lệch, không ghi log).
  2) Nếu OLD.price = NEW.price → không thay đổi giá → thoát (không INSERT log).
  3) Nếu NEW.price > OLD.price → INSERT một dòng: trạng thái 'TĂNG GIÁ',
     difference_amount = NEW.price − OLD.price.
  4) Nếu NEW.price < OLD.price → INSERT: 'GIẢM GIÁ',
     difference_amount = OLD.price − NEW.price.
*/

-- PHẦN 2 — Triển khai: bảng log + trigger
DROP TRIGGER IF EXISTS tr_Medicines_PriceChange_Log;
DROP TABLE IF EXISTS Price_Changes_Log;

CREATE TABLE Price_Changes_Log (
    log_id INT AUTO_INCREMENT PRIMARY KEY,
    medicine_id INT NOT NULL,
    old_price DECIMAL(18, 2) NOT NULL,
    new_price DECIMAL(18, 2) NOT NULL,
    change_status VARCHAR(20) NOT NULL,
    difference_amount DECIMAL(18, 2) NOT NULL,
    changed_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT fk_price_log_medicine
        FOREIGN KEY (medicine_id) REFERENCES Medicines (medicine_id)
);

DELIMITER //

CREATE TRIGGER tr_Medicines_PriceChange_Log
BEFORE UPDATE ON Medicines
FOR EACH ROW
BEGIN
    IF NEW.price <= 0 THEN
        SIGNAL SQLSTATE '45000'
            SET MESSAGE_TEXT = 'Lỗi: Giá thuốc mới không hợp lệ';
    END IF;

    IF OLD.price <> NEW.price THEN
        IF NEW.price > OLD.price THEN
            INSERT INTO Price_Changes_Log (
                medicine_id,
                old_price,
                new_price,
                change_status,
                difference_amount
            ) VALUES (
                OLD.medicine_id,
                OLD.price,
                NEW.price,
                'TĂNG GIÁ',
                NEW.price - OLD.price
            );
        ELSE
            INSERT INTO Price_Changes_Log (
                medicine_id,
                old_price,
                new_price,
                change_status,
                difference_amount
            ) VALUES (
                OLD.medicine_id,
                OLD.price,
                NEW.price,
                'GIẢM GIÁ',
                OLD.price - NEW.price
            );
        END IF;
    END IF;
END //

DELIMITER ;

-- PHẦN 3 — Kiểm thử (chạy tuần tự sau khi Medicines đúng dữ liệu mẫu bai1)

-- 3.1 Tăng giá hợp lệ (medicine_id = 1: 15000 → 16000, log: TĂNG GIÁ, 1000)
UPDATE Medicines
SET price = 16000
WHERE medicine_id = 1;

-- 3.2 Giảm giá hợp lệ (medicine_id = 2: 5000 → 4500, log: GIẢM GIÁ, 500)
UPDATE Medicines
SET price = 4500
WHERE medicine_id = 2;

-- 3.3 Chỉ đổi tên / tồn kho, giá không đổi → không sinh thêm dòng log
UPDATE Medicines
SET name = 'Amoxicillin 500mg (VI)', stock = 120
WHERE medicine_id = 1;

-- 3.4 Giá mới không hợp lệ (âm hoặc 0) → trigger chặn, thông báo đúng quy định
--     (lệnh sau phải báo lỗi; không cập nhật dòng, không ghi log.)
UPDATE Medicines
SET price = -5000
WHERE medicine_id = 1;

-- Kiểm tra nhanh sau khi chạy 3.1–3.3 (và bỏ qua lỗi ở 3.4):
-- SELECT * FROM Price_Changes_Log ORDER BY log_id;
