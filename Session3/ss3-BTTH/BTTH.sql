USE session3;

CREATE TABLE products (
    product_id VARCHAR(10) PRIMARY KEY,
    product_name VARCHAR(255) NOT NULL,
    size VARCHAR(10),
    price DECIMAL(10,2)
);

INSERT INTO products (product_id, product_name, size, price) VALUES
('P01', 'Áo sơ mi trắng', 'L', 250000),
('P02', 'Quần Jean xanh', 'M', 450000),
('P03', 'Áo thun Basic', 'XL', 150000),
('P04', 'Áo hoodie', NULL, -200000),
('P05', 'Áo khoác gió', NULL, 300000),
('P06', 'Quần short', 'S', -100000),
('P07', 'Áo polo', NULL, 350000),
('P08', 'Áo tanktop', 'M', 200000),
('P09', 'Áo len', NULL, -50000),
('P10', 'Quần jogger', 'L', 320000);

UPDATE products
SET price = 400000
WHERE product_id = 'P02';

UPDATE products
SET price = price * 1.1;

DELETE FROM products
WHERE product_id = 'P03';

SELECT * FROM products;

SELECT product_name, size FROM products;

SELECT * FROM products
WHERE price > 300000;

DELETE FROM products
WHERE size IS NULL OR price < 0;

