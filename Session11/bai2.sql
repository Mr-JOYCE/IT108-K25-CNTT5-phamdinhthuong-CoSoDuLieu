USE RikkeiClinicDB;

-- -----------------------------------------------------------------------------
-- PHẦN A — Phân tích
--
-- 1) CALL tái hiện thao tác gõ nhầm số âm cho mã vật tư item_id = 10:
--
--    CALL AddInventory(10, -500);
--
--    (Với thủ tục cũ: stock_quantity bị cộng thêm -500, tức trừ 500 khỏi tồn.)
--    Kiểm tra: SELECT item_id, item_name, stock_quantity FROM Inventory WHERE item_id = 10;
--
-- 2) Giải thích (1–2 dòng):
--    Công thức SET stock_quantity = stock_quantity + p_quantity vẫn thực hiện khi p_quantity âm,
--    nên MySQL coi đó là phép cộng số âm (tức trừ tồn) chứ không từ chối — gây mất hàng nếu không validate.

-- -----------------------------------------------------------------------------
-- PHẦN B — Sửa chữa: chỉ cộng kho khi số lượng nhập > 0

DROP PROCEDURE IF EXISTS AddInventory;

DELIMITER //

CREATE PROCEDURE AddInventory(IN p_item_id INT, IN p_quantity INT)
BEGIN
    IF p_quantity > 0 THEN
        UPDATE Inventory
        SET stock_quantity = stock_quantity + p_quantity
        WHERE item_id = p_item_id;
    END IF;
END //

DELIMITER ;
