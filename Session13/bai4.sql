USE RikkeiClinicDB;

-- PHẦN 1 — Phân tích kỹ thuật

/*
Số lượng trigger: 2 (một cho INSERT, một cho UPDATE).

Sự kiện & thời điểm:
  - BEFORE INSERT ON Appointments : chặn ngay trước khi ghi lịch mới trùng giờ.
  - BEFORE UPDATE ON Appointments  : chặn khi dời lịch / đổi bác sĩ sang mốc đã bận.

Lý do BEFORE: từ chối giao dịch sớm (không cần rollback sau INSERT/UPDATE).

Giả định khung giờ (theo schema hiện có chỉ có appointment_date): hai ca “trùng giờ” nếu
cùng doctor_id và cùng appointment_date (đúng tới giây).

Mệnh đề WHERE xử lý ngoại lệ:

  Ngoại lệ 1 — khung giờ của ca Cancelled được coi là trống:
    AND a.status <> 'Cancelled'
    (chỉ các ca khác Pending / Completed … mới được coi là chiếm slot).

  Ngoại lệ 2 — không coi chính dòng đang UPDATE là đối thủ của chính nó:
    AND a.appointment_id <> NEW.appointment_id
    (chỉ đặt trong trigger UPDATE; trigger INSERT không cần vì dòng mới chưa tồn tại).
*/

-- PHẦN 2 — Triển khai trigger

DROP TRIGGER IF EXISTS tr_Appointments_NoDoubleBooking_INSERT;
DROP TRIGGER IF EXISTS tr_Appointments_NoDoubleBooking_UPDATE;

DELIMITER //

CREATE TRIGGER tr_Appointments_NoDoubleBooking_INSERT
BEFORE INSERT ON Appointments
FOR EACH ROW
BEGIN
    IF EXISTS (
        SELECT 1
        FROM Appointments AS a
        WHERE a.doctor_id = NEW.doctor_id
          AND a.appointment_date = NEW.appointment_date
          AND a.status <> 'Cancelled'
    ) THEN
        SIGNAL SQLSTATE '45000'
            SET MESSAGE_TEXT = 'Lỗi: Bác sĩ đã có lịch hẹn vào khung giờ này';
    END IF;
END //

CREATE TRIGGER tr_Appointments_NoDoubleBooking_UPDATE
BEFORE UPDATE ON Appointments
FOR EACH ROW
BEGIN
    IF EXISTS (
        SELECT 1
        FROM Appointments AS a
        WHERE a.doctor_id = NEW.doctor_id
          AND a.appointment_date = NEW.appointment_date
          AND a.status <> 'Cancelled'
          AND a.appointment_id <> NEW.appointment_id
    ) THEN
        SIGNAL SQLSTATE '45000'
            SET MESSAGE_TEXT = 'Lỗi: Bác sĩ đã có lịch hẹn vào khung giờ này';
    END IF;
END //

DELIMITER ;

-- PHẦN 3 — Kiểm thử nghiệm thu (chạy tuần tự)

-- Giả định sau bai1:
--   104: doctor 101, 2026-06-10 08:30, Pending
--   106: doctor 101, 2026-05-02 10:00, Cancelled

-- Kịch bản 1 — Khung giờ hoàn toàn trống → thành công
INSERT INTO Appointments (appointment_id, patient_id, doctor_id, appointment_date, status)
VALUES (200, 2, 101, '2026-07-01 14:00:00', 'Pending');

-- Kịch bản 2 — Trùng giờ với ca Pending (104) → chặn & báo lỗi
INSERT INTO Appointments (appointment_id, patient_id, doctor_id, appointment_date, status)
VALUES (201, 3, 101, '2026-06-10 08:30:00', 'Pending');

-- Kịch bản 3 — Trùng giờ với ca Cancelled (106) → thành công (slot được coi là trống)
INSERT INTO Appointments (appointment_id, patient_id, doctor_id, appointment_date, status)
VALUES (202, 2, 101, '2026-05-02 10:00:00', 'Pending');

-- Kịch bản 4 — Chỉ đổi trạng thái ca hiện tại (ngoại lệ 2: không trùng với chính nó) → thành công
UPDATE Appointments
SET status = 'Completed'
WHERE appointment_id = 104;
