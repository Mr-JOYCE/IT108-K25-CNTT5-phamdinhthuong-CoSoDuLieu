USE RikkeiClinicDB;

-- PHẦN A: PHÂN TÍCH & ĐỀ XUẤT ĐA GIẢI PHÁP

-- A.1. Định nghĩa I/O
/*
Đầu vào:
  - Mã bệnh nhân      (patient_id) : INT
  - Số tiền thanh toán (amount)    : DECIMAL(18,2)

Đầu ra:
  - Thông báo trạng thái (hiển thị UI) : VARCHAR(255)

Tham số Stored Procedure:
  - IN  p_patient_id      INT
  - IN  p_amount          DECIMAL(18,2)
  - OUT p_status_message  VARCHAR(255)
*/

-- A.2. Hai chiến lược xử lý
/*
Chiến lược 1 — Chạy thẳng UPDATE, dựa Exception mặc định:
  Bọc hai lệnh UPDATE (trừ Ví, giảm Công nợ) trong START TRANSACTION rồi thực thi
  ngay. Nếu CHECK CONSTRAINT (balance >= 0) hoặc lỗi SQL xảy ra, EXIT HANDLER /
  engine tự ROLLBACK. Không đọc số dư trước khi ghi.

Chiến lược 2 — Đối chiếu dữ liệu trước, chủ động ngắt giao dịch:
  START TRANSACTION → SELECT balance ... FOR UPDATE → kiểm tra p_amount > 0,
  balance >= p_amount, ví Active → chỉ khi hợp lệ mới UPDATE Ví và Công nợ
  → COMMIT; nếu vi phạm → ROLLBACK và gán thông báo lỗi cụ thể cho OUT.
*/

-- A.3. So sánh & lựa chọn
/*
+---------------------------+----------------------------------+----------------------------------+
| Tiêu chí                  | Chiến lược 1 (Exception)         | Chiến lược 2 (Validate trước)    |
+---------------------------+----------------------------------+----------------------------------+
| Ưu điểm                   | Code gọn; DB tự rollback lỗi SQL | Thông báo lỗi rõ cho người dùng  |
|                           |                                  | Chặn âm ví / thiếu tiền chủ động |
|                           |                                  | Không phụ thuộc CHECK trên bảng  |
| Nhược điểm                | Thiếu CHECK → ví có thể âm       | Thêm vài dòng IF/SELECT          |
|                           | Thông báo lỗi khó tùy biến       |                                  |
|                           | Rủi ro mất tiền nếu lỗi giữa chừng|                                  |
|                           | khi không bọc transaction đúng   |                                  |
+---------------------------+----------------------------------+----------------------------------+
| Quyết định triển khai     | Không chọn                       | CHỌN — an toàn nghiệp vụ nhất    |
+---------------------------+----------------------------------+----------------------------------+
*/

-- PHẦN B: THIẾT KẾ & TRIỂN KHAI


-- B.1. Luồng xử lý (Chiến lược 2)
/*
  • Khởi tạo giao dịch     : START TRANSACTION (sau khi khai báo EXIT HANDLER)
  • Khóa & đọc số dư ví    : SELECT balance, status FROM Wallets ... FOR UPDATE
  • Kiểm tra nghiệp vụ     :
      - Số tiền <= 0        → ROLLBACK → thông báo lỗi số tiền không hợp lệ
      - Ví Inactive         → ROLLBACK → thông báo ví bị khóa
      - balance < p_amount  → ROLLBACK → thông báo số dư không đủ
  • Cập nhật dữ liệu       : UPDATE Wallets (trừ tiền); UPDATE Patient_Invoices (giảm nợ)
  • Xác nhận giao dịch     : COMMIT → OUT "Thanh toán thành công"
  • Hoàn tác khi lỗi hệ thống: EXIT HANDLER FOR SQLEXCEPTION → ROLLBACK
*/

-- B.2. Triển khai Procedure

DROP PROCEDURE IF EXISTS PayHospitalFee;

DELIMITER //

CREATE PROCEDURE PayHospitalFee(
    IN p_patient_id INT,
    IN p_amount DECIMAL(18,2),
    OUT p_status_message VARCHAR(255)
)
BEGIN
    DECLARE v_balance DECIMAL(18,2) DEFAULT 0;
    DECLARE v_status VARCHAR(20) DEFAULT 'Inactive';

    DECLARE EXIT HANDLER FOR SQLEXCEPTION
    BEGIN
        ROLLBACK;
        SET p_status_message = 'Lỗi: Hệ thống xử lý thất bại, giao dịch đã hoàn tác';
    END;

    START TRANSACTION;

    SELECT balance, status
    INTO v_balance, v_status
    FROM Wallets
    WHERE patient_id = p_patient_id
    FOR UPDATE;

    IF v_balance IS NULL THEN
        ROLLBACK;
        SET p_status_message = 'Lỗi: Không tìm thấy ví của bệnh nhân';
    ELSEIF p_amount <= 0 THEN
        ROLLBACK;
        SET p_status_message = 'Lỗi: Số tiền thanh toán không hợp lệ';
    ELSEIF v_status <> 'Active' THEN
        ROLLBACK;
        SET p_status_message = 'Lỗi: Ví điện tử đang bị khóa';
    ELSEIF v_balance < p_amount THEN
        ROLLBACK;
        SET p_status_message = 'Lỗi: Số dư ví không đủ';
    ELSE
        UPDATE Wallets
        SET balance = balance - p_amount
        WHERE patient_id = p_patient_id;

        UPDATE Patient_Invoices
        SET total_due = total_due - p_amount,
            last_updated = CURRENT_TIMESTAMP
        WHERE patient_id = p_patient_id;

        COMMIT;
        SET p_status_message = 'Thanh toán thành công';
    END IF;
END //

DELIMITER ;

-- B.3. NGHIỆM THU — 3 kịch bản kiểm thử


-- Đặt lại dữ liệu mẫu để kiểm thử độc lập
UPDATE Wallets SET balance = 500000.00, status = 'Active' WHERE patient_id = 1;
UPDATE Wallets SET balance = 50000.00, status = 'Active' WHERE patient_id = 2;
UPDATE Patient_Invoices SET total_due = 1500000.00 WHERE patient_id = 1;
UPDATE Patient_Invoices SET total_due = 0 WHERE patient_id = 2;

SELECT patient_id, balance, status FROM Wallets WHERE patient_id IN (1, 2);
SELECT patient_id, total_due FROM Patient_Invoices WHERE patient_id IN (1, 2);

-- (1) Giao dịch hợp lệ — BN 1, thanh toán 200.000đ (số dư 500.000đ)
CALL PayHospitalFee(1, 200000.00, @status_msg);
SELECT @status_msg AS thong_bao;
SELECT patient_id, balance FROM Wallets WHERE patient_id = 1;
SELECT patient_id, total_due FROM Patient_Invoices WHERE patient_id = 1;

-- (2) Chặn khi số dư không đủ — BN 2 (ví 50.000đ), yêu cầu 200.000đ
CALL PayHospitalFee(2, 200000.00, @status_msg);
SELECT @status_msg AS thong_bao;
SELECT patient_id, balance FROM Wallets WHERE patient_id = 2;
SELECT patient_id, total_due FROM Patient_Invoices WHERE patient_id = 2;

-- (3) Bẫy số tiền âm — BN 1, truyền -50.000đ
CALL PayHospitalFee(1, -50000.00, @status_msg);
SELECT @status_msg AS thong_bao;
SELECT patient_id, balance FROM Wallets WHERE patient_id = 1;
SELECT patient_id, total_due FROM Patient_Invoices WHERE patient_id = 1;
