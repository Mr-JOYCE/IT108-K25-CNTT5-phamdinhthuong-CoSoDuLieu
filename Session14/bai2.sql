USE RikkeiClinicDB;

-- PHẦN A: PHÂN TÍCH
/*
Việc để bệnh nhân lơ lửng không có giường (giường cũ đã trống, giường mới chưa gán)
vi phạm tính Atomicity (Nguyên tử): hai bước giải phóng và gán giường phải cùng
thành công hoặc cùng bị hủy, không được dừng giữa chừng.
*/

-- PHẦN B: SỬA CHỮA MÃ NGUỒN


DROP PROCEDURE IF EXISTS TransferBed;

DELIMITER //

CREATE PROCEDURE TransferBed(IN p_patient_id INT, IN p_new_bed_id INT)
BEGIN
    DECLARE EXIT HANDLER FOR SQLEXCEPTION
    BEGIN
        ROLLBACK;
        RESIGNAL;
    END;

    START TRANSACTION;

    -- Thao tác 1: Giải phóng giường cũ
    UPDATE Beds SET patient_id = NULL WHERE patient_id = p_patient_id;

    -- Thao tác 2: Gán giường mới
    UPDATE Beds SET patient_id = p_patient_id WHERE bed_id = p_new_bed_id;

    COMMIT;
END //

DELIMITER ;
