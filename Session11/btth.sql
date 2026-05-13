CREATE DATABASE cntt5_store_db;
USE cntt5_store_db;

CREATE TABLE IF NOT EXISTS users (
	id INT PRIMARY KEY AUTO_INCREMENT,
    full_name VARCHAR(50) NOT NULL,
    email VARCHAR(255) UNIQUE NOT NULL,
    total_spent DECIMAL(10, 0) DEFAULT 0,
    is_active BOOLEAN DEFAULT 1,
    CONSTRAINT ck_total_spent CHECK (total_spent >= 0)
);

CREATE TABLE IF NOT EXISTS products (
	id INT PRIMARY KEY AUTO_INCREMENT,
    name VARCHAR(255) NOT NULL,
    price DECIMAL(10, 0) DEFAULT 0,
    stock INT DEFAULT 0,
    CONSTRAINT ck_stock CHECK (stock >= 0),
    CONSTRAINT ck_price CHECK (price >= 0)
);

CREATE TABLE IF NOT EXISTS orders (
	id INT PRIMARY KEY AUTO_INCREMENT,
    user_id INT NOT NULL,
    product_id INT,
    quantity SMALLINT DEFAULT 0 NOT NULL,
    total_price DECIMAL(10, 0) DEFAULT 0,
    order_date TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT ck_quantity CHECK (quantity >= 0),
    CONSTRAINT ck_total_price CHECK (total_price >= 0),
    FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE,
    FOREIGN KEY (product_id) REFERENCES products(id) ON DELETE SET NULL
);

-- =========================
-- INSERT USERS (50 records)
-- =========================
INSERT INTO users (full_name, email, total_spent, is_active) VALUES
('Nguyen Van An', 'an01@gmail.com', 1250000, 1),
('Tran Thi Bich', 'bich02@gmail.com', 3400000, 1),
('Le Hoang Nam', 'nam03@gmail.com', 980000, 0),
('Pham Gia Huy', 'huy04@gmail.com', 4200000, 1),
('Vo Minh Quan', 'quan05@gmail.com', 2150000, 1),
('Dang Thu Trang', 'trang06@gmail.com', 1570000, 1),
('Bui Tuan Kiet', 'kiet07@gmail.com', 6100000, 0),
('Do Ngoc Han', 'han08@gmail.com', 2750000, 1),
('Huynh Bao Chau', 'chau09@gmail.com', 450000, 1),
('Phan Minh Tri', 'tri10@gmail.com', 3890000, 1),
('Ngo Thanh Tung', 'tung11@gmail.com', 720000, 0),
('Duong Kim Ngan', 'ngan12@gmail.com', 5100000, 1),
('Mai Quoc Viet', 'viet13@gmail.com', 1420000, 1),
('Ly Gia Bao', 'bao14@gmail.com', 830000, 1),
('Ta Thanh Phuc', 'phuc15@gmail.com', 4670000, 0),
('Nguyen Thi Yen', 'yen16@gmail.com', 2580000, 1),
('Tran Quang Hieu', 'hieu17@gmail.com', 1980000, 1),
('Le Minh Tam', 'tam18@gmail.com', 6200000, 1),
('Pham Thanh Dat', 'dat19@gmail.com', 3700000, 0),
('Vo Gia Linh', 'linh20@gmail.com', 910000, 1),
('Dang Bao Ngoc', 'ngoc21@gmail.com', 2850000, 1),
('Bui Thanh Son', 'son22@gmail.com', 760000, 1),
('Do Thi Hoa', 'hoa23@gmail.com', 5490000, 0),
('Huynh Tuan Anh', 'anh24@gmail.com', 1390000, 1),
('Phan Minh Chau', 'chau25@gmail.com', 4700000, 1),
('Ngo Thanh Ha', 'ha26@gmail.com', 1990000, 1),
('Duong Quoc Khanh', 'khanh27@gmail.com', 3120000, 0),
('Mai Hoang Long', 'long28@gmail.com', 880000, 1),
('Ly Minh Thu', 'thu29@gmail.com', 4210000, 1),
('Ta Bao Vy', 'vy30@gmail.com', 2500000, 1),
('Nguyen Gia Huy', 'huy31@gmail.com', 690000, 0),
('Tran Minh Khoa', 'khoa32@gmail.com', 5710000, 1),
('Le Thanh Tung', 'tung33@gmail.com', 1470000, 1),
('Pham Bao Han', 'han34@gmail.com', 3180000, 1),
('Vo Minh Chau', 'chau35@gmail.com', 4950000, 0),
('Dang Tuan Khang', 'khang36@gmail.com', 870000, 1),
('Bui Gia Linh', 'linh37@gmail.com', 2290000, 1),
('Do Quoc Bao', 'bao38@gmail.com', 6450000, 1),
('Huynh Thanh Truc', 'truc39@gmail.com', 1750000, 0),
('Phan Bao Nam', 'nam40@gmail.com', 3890000, 1),
('Ngo Minh Quan', 'quan41@gmail.com', 950000, 1),
('Duong Thi Mai', 'mai42@gmail.com', 5300000, 1),
('Mai Thanh Dat', 'dat43@gmail.com', 2650000, 0),
('Ly Bao Chau', 'chau44@gmail.com', 4100000, 1),
('Ta Minh Kiet', 'kiet45@gmail.com', 1230000, 1),
('Nguyen Thanh Son', 'son46@gmail.com', 3570000, 1),
('Tran Gia Bao', 'bao47@gmail.com', 7200000, 0),
('Le Minh Anh', 'anh48@gmail.com', 820000, 1),
('Pham Bao Ngoc', 'ngoc49@gmail.com', 2980000, 1),
('Vo Thanh Huyen', 'huyen50@gmail.com', 4690000, 1);

-- ============================
-- INSERT PRODUCTS (50 records)
-- ============================
INSERT INTO products (name, price, stock) VALUES
('iPhone 15', 25000000, 15),
('Samsung Galaxy S24', 22000000, 20),
('MacBook Air M3', 32000000, 10),
('Dell XPS 13', 28000000, 12),
('Asus ROG Strix', 35000000, 8),
('AirPods Pro', 6500000, 30),
('Logitech MX Master 3S', 2500000, 25),
('Sony WH-1000XM5', 8900000, 18),
('iPad Air', 17000000, 14),
('Apple Watch Series 9', 12000000, 16),
('Xiaomi Redmi Note 13', 7000000, 40),
('Samsung A55', 9500000, 28),
('HP Pavilion 15', 21000000, 11),
('Lenovo ThinkPad X1', 29000000, 9),
('MSI Gaming Laptop', 33000000, 7),
('Razer DeathAdder V3', 1800000, 35),
('Corsair K70 Keyboard', 3200000, 22),
('LG UltraWide Monitor', 9800000, 13),
('Acer Nitro 5', 24000000, 10),
('Canon EOS M50', 16500000, 6),
('Nikon D5600', 14500000, 5),
('GoPro Hero 12', 11000000, 17),
('JBL Charge 5', 3200000, 26),
('Marshall Stanmore II', 9500000, 9),
('Kindle Paperwhite', 4200000, 19),
('TP-Link Archer AX55', 2800000, 24),
('Samsung SSD 1TB', 2600000, 31),
('WD External HDD 2TB', 2300000, 27),
('Apple Magic Mouse', 2100000, 15),
('Anker Power Bank', 1200000, 45),
('Baseus Charger 65W', 890000, 50),
('Huawei MatePad', 8900000, 14),
('Asus ZenBook 14', 27000000, 8),
('Dell Inspiron 15', 19500000, 12),
('Logitech C920 Webcam', 1900000, 29),
('HyperX Cloud II', 2500000, 21),
('SteelSeries Apex 7', 3400000, 16),
('BenQ 27 Inch Monitor', 7600000, 11),
('Sony Alpha A6400', 23000000, 5),
('DJI Mini 4 Pro', 25000000, 4),
('Nintendo Switch OLED', 8900000, 18),
('PlayStation 5', 14500000, 9),
('Xbox Series X', 13800000, 7),
('Asus TUF Gaming F15', 26000000, 10),
('Gigabyte RTX 4070', 21500000, 6),
('Intel Core i7 14700K', 11800000, 13),
('AMD Ryzen 7 7800X', 10500000, 14),
('Kingston Fury 32GB RAM', 3200000, 20),
('Samsung 49 Inch TV', 28000000, 5),
('LG OLED C3', 35000000, 3);

-- ==========================
-- INSERT ORDERS (50 records)
-- ==========================
INSERT INTO orders (user_id, product_id, quantity, total_price) VALUES
(1, 1, 1, 25000000),
(2, 6, 2, 13000000),
(3, 10, 1, 12000000),
(4, 3, 1, 32000000),
(5, 5, 1, 35000000),
(6, 11, 2, 14000000),
(7, 7, 1, 2500000),
(8, 8, 1, 8900000),
(9, 9, 1, 17000000),
(10, 2, 1, 22000000),
(11, 15, 1, 33000000),
(12, 20, 1, 16500000),
(13, 13, 1, 21000000),
(14, 18, 2, 19600000),
(15, 22, 1, 11000000),
(16, 30, 3, 3600000),
(17, 25, 1, 4200000),
(18, 14, 1, 29000000),
(19, 19, 1, 24000000),
(20, 12, 2, 19000000),
(21, 24, 1, 9500000),
(22, 21, 1, 14500000),
(23, 16, 2, 3600000),
(24, 17, 1, 3200000),
(25, 26, 1, 2800000),
(26, 27, 2, 5200000),
(27, 28, 1, 2300000),
(28, 29, 1, 2100000),
(29, 31, 2, 1780000),
(30, 32, 1, 8900000),
(31, 33, 1, 27000000),
(32, 34, 1, 19500000),
(33, 35, 2, 3800000),
(34, 36, 1, 2500000),
(35, 37, 1, 3400000),
(36, 38, 1, 7600000),
(37, 39, 1, 23000000),
(38, 40, 1, 25000000),
(39, 41, 1, 8900000),
(40, 42, 1, 14500000),
(41, 43, 1, 13800000),
(42, 44, 1, 26000000),
(43, 45, 1, 21500000),
(44, 46, 1, 11800000),
(45, 47, 1, 10500000),
(46, 48, 2, 6400000),
(47, 49, 1, 28000000),
(48, 50, 1, 35000000),
(49, 4, 1, 28000000),
(50, 23, 2, 6400000);

-- Truy van co ban 

-- Cau 1:

DROP PROCEDURE IF EXISTS GetUserInfo;

DELIMITER //
CREATE PROCEDURE GetUserInfo(p_user_id INT)
BEGIN
    SELECT * 
    FROM users 
    WHERE id = p_user_id;
END //
DELIMITER ;

CALL GetUserInfo(1);

-- cau 2:

DELIMITER //
CREATE PROCEDURE add_new_product(product_name VARCHAR(100), price DECIMAL(10, 0), stock INT)
BEGIN
    IF price <= 0 THEN 
        SELECT "Gia phai lon hon 0";
    ELSE 
        INSERT INTO products (name, price, stock) VALUES (product_name, price, stock);
    END IF;
END //
DELIMITER ;

CALL add_new_product('iPhone 16', 28000000, 15);

-- Cau 3:

DROP PROCEDURE IF EXISTS calculate_discount_price;

DELIMITER //

CREATE PROCEDURE calculate_discount_price(
    IN p_product_id INT, 
    IN p_discount TINYINT
)
BEGIN
    -- 1. Kiểm tra xem discount có hợp lệ không (0 - 100%)
    IF p_discount < 0 OR p_discount > 100 THEN
        SIGNAL SQLSTATE '45000' 
        SET MESSAGE_TEXT = 'Lỗi: Mức giảm giá (discount) phải nằm trong khoảng từ 0 đến 100.';
    ELSE
        -- 2. Tính toán và gán giá trị vào biến OUT
        SELECT CEIL(price * (1 - p_discount / 100))
        FROM products
        WHERE id = p_product_id;
    END IF;
END //

DELIMITER ;


-- Cau 4 
DELIMITER //

CREATE PROCEDURE GetTotalRevenueByMonth(
    IN p_Month TINYINT,
    IN p_year INT,
    OUT p_total_revenue DECIMAL(10, 0)
)
BEGIN
    SELECT SUM(total_price) INTO p_total_revenue
    FROM orders
    WHERE MONTH(order_date) = p_Month AND YEAR(order_date) = p_year;
END //

DELIMITER ;






