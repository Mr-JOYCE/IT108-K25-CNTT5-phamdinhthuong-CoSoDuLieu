CREATE DATABASE Session3;

CREATE TABLE PRODUCTS (
ProductID INT PRIMARY KEY,
ProductName VARCHAR(100),
Category VARCHAR(50),
OriginalPrice DECIMAL(18, 2)
);

INSERT INTO PRODUCTS (ProductID, ProductName, Category, OriginalPrice)
VALUES
(1, 'iPhone 15', 'Electronics', 20000000),
(2, 'Samsung Refrigerator', 'Electronics', 15000000),
(3, 'Water Spinach', 'Food', 10000),
(4, 'Filtered Fresh Milk 4', 'Food', 28000);

-- Vì nhân viên không hiểu rõ yêu cầu "Giảm giá 10% cho tất cả sản phẩm thuộc ngành hàng Điện tử (Electronics)"
-- Thiếu điều kiện Where Category = 'Electronics' nên đã cập nhật lại giá của toàn bộ sản phẩm

UPDATE PRODUCTS
SET OriginalPrice = OriginalPrice * 0.9
WHERE Category = 'Electronics';