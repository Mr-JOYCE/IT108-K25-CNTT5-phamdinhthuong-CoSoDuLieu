USE RikkeiClinicDB;

-- PHẦN A: PHÂN TÍCH & THIẾT KẾ

-- A.1. Phân tích I/O
/*
Đầu vào (từ Backend):
  - Mã bệnh nhân  (patient_id)  : INT
  - Mã sản phẩm   (product_id)  : INT
  - Số lượng mua  (quantity)    : INT

Đầu ra (hiển thị UI):
  - Thông báo trạng thái : VARCHAR(255)

Đề xuất tham số Stored Procedure:
  - IN  p_patient_id, p_product_id, p_quantity  — Backend chỉ gửi dữ liệu vào
  - OUT p_status_message                        — Procedure ghi kết quả trả về

Lý do dùng OUT (không dùng INOUT):
  Thông báo trạng thái chỉ do Procedure sinh ra sau khi xử lý; caller không cần
  truyền sẵn giá trị vào. OUT thể hiện đúng chiều dữ liệu (DB → Backend) và
  tránh ghi đè nhầm biến đầu vào của ứng dụng.
*/

-- A.2. Thiết kế luồng xử lý
/*
  • Khai báo EXIT HANDLER FOR SQLEXCEPTION → ROLLBACK khi lỗi hệ thống bất ngờ
  • START TRANSACTION — gom trừ kho + trừ ví thành một khối nguyên tử

  Biến cục bộ:
    v_stock          INT           — tồn kho sản phẩm (đọc có khóa)
    v_price          DECIMAL(18,2) — đơn giá sản phẩm
    v_balance        DECIMAL(18,2) — số dư ví
    v_wallet_status  VARCHAR(20)   — trạng thái ví ('Active' / 'Inactive')
    v_line_total     DECIMAL(18,2) — thành tiền = quantity × price

  Các bước logic:
  1. SELECT Products (stock, price) ... FOR UPDATE
  2. SELECT Wallets (balance, status) ... FOR UPDATE
  3. Kiểm tra nghiệp vụ (chưa UPDATE — tránh trừ kho rồi mới phát hiện lỗi ví):
       - Sản phẩm không tồn tại
       - quantity <= 0
       - Ví Inactive        → ROLLBACK → "Thất bại: Ví đang bị khóa"
       - quantity > stock   → ROLLBACK → "Thất bại: Kho không đủ sản phẩm"
       - line_total > balance → ROLLBACK → "Thất bại: Số dư ví không đủ"
  4. UPDATE Products SET stock = stock - quantity
  5. UPDATE Wallets SET balance = balance - line_total
  6. COMMIT → OUT "Thành công: Đã xử lý đơn hàng"
*/

-- PHẦN B: TRIỂN KHAI

DROP PROCEDURE IF EXISTS ProcessEquipmentPurchase;

DELIMITER //

CREATE PROCEDURE ProcessEquipmentPurchase(
    IN p_patient_id INT,
    IN p_product_id INT,
    IN p_quantity INT,
    OUT p_status_message VARCHAR(255)
)
BEGIN
    DECLARE v_stock INT DEFAULT 0;
    DECLARE v_price DECIMAL(18,2) DEFAULT 0;
    DECLARE v_balance DECIMAL(18,2) DEFAULT 0;
    DECLARE v_wallet_status VARCHAR(20) DEFAULT 'Inactive';
    DECLARE v_line_total DECIMAL(18,2) DEFAULT 0;

    DECLARE EXIT HANDLER FOR SQLEXCEPTION
    BEGIN
        ROLLBACK;
        SET p_status_message = 'Lỗi: Hệ thống xử lý thất bại, giao dịch đã hoàn tác';
    END;

    START TRANSACTION;

    SELECT stock, price
    INTO v_stock, v_price
    FROM Products
    WHERE product_id = p_product_id
    FOR UPDATE;

    SELECT balance, status
    INTO v_balance, v_wallet_status
    FROM Wallets
    WHERE patient_id = p_patient_id
    FOR UPDATE;

    IF v_price IS NULL OR v_stock IS NULL THEN
        ROLLBACK;
        SET p_status_message = 'Thất bại: Không tìm thấy sản phẩm';
    ELSEIF v_balance IS NULL THEN
        ROLLBACK;
        SET p_status_message = 'Thất bại: Không tìm thấy ví bệnh nhân';
    ELSEIF p_quantity <= 0 THEN
        ROLLBACK;
        SET p_status_message = 'Thất bại: Số lượng mua không hợp lệ';
    ELSEIF v_wallet_status <> 'Active' THEN
        ROLLBACK;
        SET p_status_message = 'Thất bại: Ví đang bị khóa';
    ELSEIF p_quantity > v_stock THEN
        ROLLBACK;
        SET p_status_message = 'Thất bại: Kho không đủ sản phẩm';
    ELSE
        SET v_line_total = p_quantity * v_price;

        IF v_line_total > v_balance THEN
            ROLLBACK;
            SET p_status_message = 'Thất bại: Số dư ví không đủ';
        ELSE
            UPDATE Products
            SET stock = stock - p_quantity
            WHERE product_id = p_product_id;

            UPDATE Wallets
            SET balance = balance - v_line_total
            WHERE patient_id = p_patient_id;

            COMMIT;
            SET p_status_message = 'Thành công: Đã xử lý đơn hàng';
        END IF;
    END IF;
END //

DELIMITER ;

-- KIỂM THỬ — Khôi phục dữ liệu mẫu (bai1.sql)
/*
  Products: id 1 — Omron 850.000đ, tồn 20 | id 2 — Máy đường huyết 450.000đ, tồn 15
  Wallets:  BN 1 — 500.000 Active | BN 2 — 50.000 Active | BN 3 — 1.000.000 Inactive
*/

UPDATE Products SET stock = 20, price = 850000.00 WHERE product_id = 1;
UPDATE Products SET stock = 15, price = 450000.00 WHERE product_id = 2;
UPDATE Wallets SET balance = 500000.00, status = 'Active' WHERE patient_id = 1;
UPDATE Wallets SET balance = 50000.00, status = 'Active' WHERE patient_id = 2;
UPDATE Wallets SET balance = 1000000.00, status = 'Inactive' WHERE patient_id = 3;

SELECT product_id, name, stock, price FROM Products WHERE product_id IN (1, 2);
SELECT patient_id, balance, status FROM Wallets WHERE patient_id IN (1, 2, 3);

-- (1) Mua hàng hợp lệ — BN 1, sản phẩm 2, SL 1 (450.000đ ≤ 500.000đ)
CALL ProcessEquipmentPurchase(1, 2, 1, @msg);
SELECT @msg AS thong_bao;
SELECT product_id, stock FROM Products WHERE product_id = 2;
SELECT patient_id, balance FROM Wallets WHERE patient_id = 1;

-- Reset sau test (1)
UPDATE Products SET stock = 15 WHERE product_id = 2;
UPDATE Wallets SET balance = 500000.00 WHERE patient_id = 1;

-- (2) Out of stock — BN 1, sản phẩm 2 (tồn 15), yêu cầu 100
CALL ProcessEquipmentPurchase(1, 2, 100, @msg);
SELECT @msg AS thong_bao;
SELECT product_id, stock FROM Products WHERE product_id = 2;
SELECT patient_id, balance FROM Wallets WHERE patient_id = 1;

-- (3) Insufficient funds — BN 2 (50.000đ), sản phẩm 1 (850.000đ), SL 1
CALL ProcessEquipmentPurchase(2, 1, 1, @msg);
SELECT @msg AS thong_bao;
SELECT product_id, stock FROM Products WHERE product_id = 1;
SELECT patient_id, balance FROM Wallets WHERE patient_id = 2;

-- (4) Locked Account — BN 3 (Inactive, 1.000.000đ), sản phẩm 2, SL 1
CALL ProcessEquipmentPurchase(3, 2, 1, @msg);
SELECT @msg AS thong_bao;
SELECT product_id, stock FROM Products WHERE product_id = 2;
SELECT patient_id, balance, status FROM Wallets WHERE patient_id = 3;
