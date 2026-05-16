USE RikkeiClinicDB;

-- Phần A: Phân tích

-- 1) UPDATE tái hiện lỗi khi Trigger SAI (IF NEW.status = 'Completed'):
--    Thao tác hợp lệ Pending → Completed nhưng vẫn bị SIGNAL vì điều kiện nhìn NEW.

/*
UPDATE Appointments
SET status = 'Completed'
WHERE appointment_id = 104;
*/

-- 2) Giải thích ngắn:
-- Phải dùng OLD: OLD.status là trạng thái đã lưu trước lần UPDATE này — chỉ OLD cho biết
-- lịch đã "Completed" (đóng sổ) từ trước hay chưa; NEW là giá trị sau khi gán, không mô tả trạng thái lịch sử trước khi sửa.

-- Phần B: Sửa chữa — xóa trigger cũ và tạo lại đúng logic (chặn khi ĐÃ Completed)
DROP TRIGGER IF EXISTS PreventStatusRevert;

DELIMITER //

CREATE TRIGGER PreventStatusRevert
BEFORE UPDATE ON Appointments
FOR EACH ROW
BEGIN
    IF OLD.status = 'Completed' THEN
        SIGNAL SQLSTATE '45000'
            SET MESSAGE_TEXT = 'Lỗi: Không được phép thao tác trên lịch khám này!';
    END IF;
END //

DELIMITER ;
