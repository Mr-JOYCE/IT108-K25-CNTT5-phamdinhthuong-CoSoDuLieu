USE session3;

CREATE TABLE CART_ITEMS (
    CartID INT NOT NULL,
    ProductID INT NOT NULL,
    Quantity INT NOT NULL,
    AddedDate DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    PRIMARY KEY (CartID, ProductID),
    CONSTRAINT chk_cart_items_quantity_positive CHECK (Quantity > 0)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- 1) Add to cart (INSERT)
-- Edge case:
-- - So luong am/0 => khong chen (WHERE 2 > 0)
-- - San pham da ton tai trong cung gio => cong don so luong
INSERT INTO CART_ITEMS (CartID, ProductID, Quantity, AddedDate)
SELECT 1001, 10, 2, NOW()
WHERE 2 > 0
ON DUPLICATE KEY UPDATE
    Quantity = Quantity + VALUES(Quantity),
    AddedDate = NOW();

-- 2) View cart (SELECT)
SELECT ProductID, Quantity, AddedDate
FROM CART_ITEMS
WHERE CartID = 1001;

-- 3) Update quantity (UPDATE)
-- Edge case: chi cap nhat khi so luong moi > 0
UPDATE CART_ITEMS
SET Quantity = 5
WHERE CartID = 1001
  AND ProductID = 10
  AND 5 > 0;

-- 4) Remove item (DELETE)
DELETE FROM CART_ITEMS
WHERE CartID = 1001
  AND ProductID = 10;
