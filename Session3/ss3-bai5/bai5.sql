USE session3;

CREATE TABLE CART_ITEMS (
CartItemID INT PRIMARY KEY AUTO_INCREMENT,
UserID INT,
ProductID INT,
Quantity INT,
AddedDate DATETIME DEFAULT CURRENT_TIMESTAMP
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- Nếu sản phẩm chưa có trong giỏ thì thêm mới
INSERT INTO CART_ITEMS (UserID, ProductID, Quantity, AddedDate)
VALUES (123, 10, 1, NOW())
ON DUPLICATE KEY UPDATE Quantity = Quantity + VALUES(Quantity);

SELECT ProductID, Quantity, AddedDate
FROM CART_ITEMS
WHERE UserID = 123;

UPDATE CART_ITEMS
SET Quantity = 5
WHERE UserID = 123 AND ProductID = 10 AND Quantity > 0;

DELETE FROM CART_ITEMS
WHERE UserID = 123 AND ProductID = 10;
