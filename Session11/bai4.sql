USE RikkeiClinicDB;

-- PHẦN A: PHÂN TÍCH & ĐỀ XUẤT ĐA GIẢI PHÁP
--
-- 1) Định nghĩa I/O (số lượng & loại tham số)
--
--    IN  p_patient_id  INT          — Mã bệnh nhân (có thể NULL nếu chỉ tra SĐT)
--    IN  p_phone       VARCHAR(20)  — Số điện thoại (có thể NULL nếu chỉ tra ID)
--    OUT p_total_due   DECIMAL(18,2) — Tổng nợ hiển thị cho Frontend
--    OUT p_status_message VARCHAR(255) — Thông báo trạng thái (lỗi / không thấy / thành công)
--
--    Không cần INOUT vì không ghi đè lại giá trị đầu vào; chỉ đọc IN và ghi OUT.
--
-- 2) Hai cách xử lý logic "theo ID hoặc Phone" (mô tả bằng lời)
--
--    Cách 1 — Rẽ nhánh IF / ELSEIF:
--    Kiểm tra NULL sớm; sau đó nếu chỉ có ID thì SELECT ... WHERE patient_id = ?;
--    nếu chỉ có Phone thì SELECT ... WHERE phone = ?; nếu có cả hai thì WHERE
--    patient_id = ? AND phone = ? để khớp đúng một bệnh nhân. Mỗi nhánh một câu
--    truy vấn (có thể copy điều kiện JOIN tới Patient_Invoices).
--
--    Cách 2 — Mệnh đề WHERE linh hoạt (một câu SELECT):
--    WHERE (p_patient_id IS NULL OR patient_id = p_patient_id)
--      AND (p_phone IS NULL OR phone = p_phone)
--    Khi chỉ truyền ID, vế phone trở thành "luôn đúng"; chỉ truyền Phone thì
--    vế ID "luôn đúng"; truyền cả hai thì cả hai vế phải khớp. Phải chặn trước
--    trường hợp cả hai IN đều NULL để không mở toàn bộ bảng.
--
-- 3) So sánh & lựa chọn
--
--    +------------------+----------------------------------+--------------------------------+
--    | Tiêu chí         | Cách 1: Rẽ nhánh nhiều truy vấn  | Cách 2: WHERE linh hoạt       |
--    +------------------+----------------------------------+--------------------------------+
--    | Ưu điểm          | Dễ đọc từng kịch bản; tách bạch | Một truy vấn; ít trùng lặp SQL |
--    | Nhược điểm       | Trùng lặp JOIN/SELECT            | Phải cẩn thận NULL & bước chặn |
--    | Bảo trì          | Sửa JOIN phải sửa nhiều chỗ    | Sửa một chỗ                    |
--    +------------------+----------------------------------+--------------------------------+
--
--    Lựa chọn: Cách 2 (WHERE linh hoạt) + bước kiểm tra đầu vào đầu tiên (chặn
--    cả hai NULL), vì đủ an toàn, gọn, và đúng một luồng truy xuất sau validate.

-- PHẦN B: THIẾT KẾ & TRIỂN KHAI
--
-- Luồng xử lý (giải pháp đã chọn):
--   - Bước 1: Nếu cả p_patient_id và p_phone đều NULL → gán nợ = 0, thông báo
--            lỗi yêu cầu nhập ít nhất một trong hai; KẾT THÚC (không SELECT full).
--   - Bước 2: Đếm số bản ghi Patients thỏa điều kiện WHERE linh hoạt ở trên.
--   - Bước 3: Nếu đếm = 0 → nợ = 0, thông báo không tìm thấy.
--   - Bước 4: Ngược lại → SELECT LEFT JOIN Patient_Invoices, COALESCE(total_due,0),
--            thông báo tra cứu thành công.

DROP PROCEDURE IF EXISTS GetPatientDebt;

DELIMITER //

CREATE PROCEDURE GetPatientDebt(
    IN  p_patient_id INT,
    IN  p_phone VARCHAR(20),
    OUT p_total_due DECIMAL(18,2),
    OUT p_status_message VARCHAR(255)
)
BEGIN
    DECLARE v_cnt INT DEFAULT 0;

    IF p_patient_id IS NULL AND p_phone IS NULL THEN
        SET p_total_due = 0;
        SET p_status_message = 'Lỗi: Chưa nhập mã bệnh nhân hoặc số điện thoại.';
    ELSE
        SELECT COUNT(*) INTO v_cnt
        FROM Patients p
        WHERE (p_patient_id IS NULL OR p.patient_id = p_patient_id)
          AND (p_phone IS NULL OR p.phone = p_phone);

        IF v_cnt = 0 THEN
            SET p_total_due = 0;
            SET p_status_message = 'Không tìm thấy bệnh nhân trong hệ thống.';
        ELSE
            SELECT COALESCE(pi.total_due, 0) INTO p_total_due
            FROM Patients p
            LEFT JOIN Patient_Invoices pi ON pi.patient_id = p.patient_id
            WHERE (p_patient_id IS NULL OR p.patient_id = p_patient_id)
              AND (p_phone IS NULL OR p.phone = p_phone)
            LIMIT 1;

            SET p_status_message = 'Tra cứu thành công.';
        END IF;
    END IF;
END //

DELIMITER ;

-- Nghiệm thu: 4 CALL — (1) chỉ ID, (2) chỉ Phone, (3) cả hai NULL, (4) không tồn tại

SET @no := NULL, @tb := NULL;

-- (1) Chỉ truyền ID (BN 1 có nợ 1.500.000 trong Patient_Invoices mẫu bai1.sql)
CALL GetPatientDebt(1, NULL, @no, @tb);
SELECT @no AS tong_no, @tb AS thong_bao;

-- (2) Chỉ truyền Phone
CALL GetPatientDebt(NULL, '0901111222', @no, @tb);
SELECT @no AS tong_no, @tb AS thong_bao;

-- (3) Cả hai NULL — chặn, không quét toàn bộ DB
CALL GetPatientDebt(NULL, NULL, @no, @tb);
SELECT @no AS tong_no, @tb AS thong_bao;

-- (4) Dữ liệu không tồn tại
CALL GetPatientDebt(99999, NULL, @no, @tb);
SELECT @no AS tong_no, @tb AS thong_bao;
