-- =========================================================
-- Session 8 - Bai tap thuc hanh SQL nang cao
-- He thong Quan ly Ban hang (Sales Management System)
-- DBMS target: MySQL 8+
-- =========================================================

-- =========================================================
-- PHAN I - THIET KE & TAO BANG (DDL)
-- =========================================================

DROP DATABASE IF EXISTS sales_management;
CREATE DATABASE sales_management;
USE sales_management;

-- 1) Customer
CREATE TABLE Customer (
    customer_id INT PRIMARY KEY AUTO_INCREMENT,
    full_name VARCHAR(100) NOT NULL,
    email VARCHAR(100) NOT NULL UNIQUE,
    gender CHAR(1) NOT NULL CHECK (gender IN ('M', 'F')),
    birth_date DATE NOT NULL
);

-- 2) Category
CREATE TABLE Category (
    category_id INT PRIMARY KEY AUTO_INCREMENT,
    category_name VARCHAR(100) NOT NULL UNIQUE
);

-- 3) Product
CREATE TABLE Product (
    product_id INT PRIMARY KEY AUTO_INCREMENT,
    product_name VARCHAR(150) NOT NULL,
    price DECIMAL(12,2) NOT NULL CHECK (price > 0),
    category_id INT NOT NULL,
    CONSTRAINT fk_product_category
        FOREIGN KEY (category_id) REFERENCES Category(category_id)
);

-- 4) `Order` (dat ten bang la `Orders` de tranh xung dot tu khoa)
CREATE TABLE Orders (
    order_id INT PRIMARY KEY AUTO_INCREMENT,
    customer_id INT NOT NULL,
    order_date DATE NOT NULL,
    CONSTRAINT fk_orders_customer
        FOREIGN KEY (customer_id) REFERENCES Customer(customer_id)
);

-- 5) Order_Detail
CREATE TABLE Order_Detail (
    order_id INT NOT NULL,
    product_id INT NOT NULL,
    quantity INT NOT NULL CHECK (quantity > 0),
    unit_price DECIMAL(12,2) NOT NULL CHECK (unit_price > 0),
    PRIMARY KEY (order_id, product_id),
    CONSTRAINT fk_order_detail_order
        FOREIGN KEY (order_id) REFERENCES Orders(order_id)
        ON DELETE CASCADE,
    CONSTRAINT fk_order_detail_product
        FOREIGN KEY (product_id) REFERENCES Product(product_id)
);

-- =========================================================
-- PHAN II - NHAP DU LIEU BAN DAU
-- Yeu cau: it nhat 5 ban ghi moi bang
-- =========================================================

-- Customer (6 ban ghi)
INSERT INTO Customer (full_name, email, gender, birth_date) VALUES
('Nguyen Van An', 'an.nguyen@gmail.com', 'M', '1998-03-15'),
('Tran Thi Bich', 'bich.tran@gmail.com', 'F', '2001-07-22'),
('Le Hoang Nam', 'nam.le@gmail.com', 'M', '2003-12-01'),
('Pham Thu Ha', 'ha.pham@gmail.com', 'F', '1995-05-09'),
('Do Minh Khang', 'khang.do@gmail.com', 'M', '2006-02-18'),
('Vu Ngoc Lan', 'lan.vu@gmail.com', 'F', '2000-10-30');

-- Category (5 ban ghi)
INSERT INTO Category (category_name) VALUES
('Dien tu'),
('Thoi trang'),
('Gia dung'),
('Sach'),
('My pham');

-- Product (10 ban ghi)
INSERT INTO Product (product_name, price, category_id) VALUES
('iPhone 15', 22000000, 1),
('Tai nghe Bluetooth', 1200000, 1),
('Ao so mi nam', 450000, 2),
('Vay cong so nu', 650000, 2),
('Noi chien khong dau', 1800000, 3),
('May xay sinh to', 900000, 3),
('Sach SQL nang cao', 250000, 4),
('Sach Python can ban', 190000, 4),
('Son moi cao cap', 420000, 5),
('Kem duong da', 380000, 5);

-- Orders (6 ban ghi)
INSERT INTO Orders (customer_id, order_date) VALUES
(1, '2026-04-01'),
(2, '2026-04-03'),
(1, '2026-04-08'),
(4, '2026-04-10'),
(6, '2026-04-15'),
(2, '2026-04-18');

-- Order_Detail (12 ban ghi)
INSERT INTO Order_Detail (order_id, product_id, quantity, unit_price) VALUES
(1, 1, 1, 22000000),
(1, 2, 2, 1200000),
(2, 3, 1, 450000),
(2, 9, 2, 420000),
(3, 7, 3, 250000),
(3, 8, 1, 190000),
(4, 5, 1, 1800000),
(4, 6, 1, 900000),
(5, 4, 2, 650000),
(5, 10, 1, 380000),
(6, 2, 1, 1200000),
(6, 3, 2, 450000);

-- =========================================================
-- PHAN III - CAP NHAT DU LIEU
-- =========================================================

-- 1) Cap nhat gia ban cho mot san pham
UPDATE Product
SET price = 23000000
WHERE product_name = 'iPhone 15';

-- 2) Cap nhat email cho mot khach hang
UPDATE Customer
SET email = 'an.nguyen.new@gmail.com'
WHERE customer_id = 1;

-- =========================================================
-- PHAN IV - XOA DU LIEU
-- =========================================================

-- Xoa mot ban ghi chi tiet don hang khong hop le (vi du don 6, san pham 3)
DELETE FROM Order_Detail
WHERE order_id = 6 AND product_id = 3;

-- =========================================================
-- PHAN V - TRUY VAN DU LIEU NANG CAO
-- =========================================================

-- 1) Danh sach khach hang + CASE hien thi gioi tinh, AS dat ten cot
SELECT
    c.full_name AS customer_name,
    c.email AS customer_email,
    CASE
        WHEN c.gender = 'M' THEN 'Nam'
        WHEN c.gender = 'F' THEN 'Nu'
        ELSE 'Khac'
    END AS gender_text
FROM Customer c;

-- 2) 3 khach hang tre tuoi nhat (tuoi nho nhat) su dung YEAR() va NOW()
SELECT
    c.customer_id,
    c.full_name,
    c.birth_date,
    (YEAR(NOW()) - YEAR(c.birth_date)) AS age
FROM Customer c
ORDER BY age ASC, c.birth_date DESC
LIMIT 3;

-- 3) Tat ca don hang kem ten khach hang (INNER JOIN)
SELECT
    o.order_id,
    o.order_date,
    c.customer_id,
    c.full_name AS customer_name
FROM Orders o
INNER JOIN Customer c ON o.customer_id = c.customer_id
ORDER BY o.order_date, o.order_id;  

-- 4) Dem so luong san pham theo tung danh muc
-- Chi hien thi danh muc co tu 2 san pham tro len
SELECT
    ct.category_id,
    ct.category_name,
    COUNT(p.product_id) AS product_count
FROM Category ct
LEFT JOIN Product p ON ct.category_id = p.category_id
GROUP BY ct.category_id, ct.category_name
HAVING COUNT(p.product_id) >= 2
ORDER BY product_count DESC, ct.category_name;

-- 5) Scalar Subquery: San pham co gia > gia trung binh toan bo san pham
SELECT
    p.product_id,
    p.product_name,
    p.price
FROM Product p
WHERE p.price > (
    SELECT AVG(price) FROM Product
)
ORDER BY p.price DESC;

-- 6) Column Subquery: Khach hang chua tung dat don (NOT IN)
SELECT
    c.customer_id,
    c.full_name,
    c.email
FROM Customer c
WHERE c.customer_id NOT IN (
    SELECT o.customer_id
    FROM Orders o
)
ORDER BY c.customer_id;

-- 7) Subquery voi ham tong hop:
-- Tim danh muc co tong doanh thu > 120% doanh thu trung binh theo danh muc
SELECT
    t.category_id,
    t.category_name,
    t.total_revenue
FROM (
    SELECT
        ct.category_id,
        ct.category_name,
        COALESCE(SUM(od.quantity * od.unit_price), 0) AS total_revenue
    FROM Category ct
    LEFT JOIN Product p ON p.category_id = ct.category_id
    LEFT JOIN Order_Detail od ON od.product_id = p.product_id
    GROUP BY ct.category_id, ct.category_name
) t
WHERE t.total_revenue > 1.2 * (
    SELECT AVG(t2.total_revenue)
    FROM (
        SELECT
            ct2.category_id,
            COALESCE(SUM(od2.quantity * od2.unit_price), 0) AS total_revenue
        FROM Category ct2
        LEFT JOIN Product p2 ON p2.category_id = ct2.category_id
        LEFT JOIN Order_Detail od2 ON od2.product_id = p2.product_id
        GROUP BY ct2.category_id
    ) t2
)
ORDER BY t.total_revenue DESC;

-- 8) Correlated Subquery:
-- San pham co gia dat nhat trong tung danh muc
SELECT
    p.product_id,
    p.product_name,
    p.price,
    ct.category_name
FROM Product p
INNER JOIN Category ct ON p.category_id = ct.category_id
WHERE p.price = (
    SELECT MAX(p2.price)
    FROM Product p2
    WHERE p2.category_id = p.category_id
)
ORDER BY ct.category_name, p.product_name;

-- 9) Truy van long nhieu cap (>= 3 cap):
-- Ho ten khach hang VIP da tung mua san pham thuoc danh muc 'Dien tu'
-- VIP o day quy uoc la tong chi tieu >= 5,000,000
SELECT c.full_name
FROM Customer c
WHERE c.customer_id IN (
    SELECT o.customer_id
    FROM Orders o
    WHERE o.order_id IN (
        SELECT od.order_id
        FROM Order_Detail od
        WHERE od.product_id IN (
            SELECT p.product_id
            FROM Product p
            WHERE p.category_id = (
                SELECT ct.category_id
                FROM Category ct
                WHERE ct.category_name = 'Dien tu'
            )
        )
    )
)
AND c.customer_id IN (
    SELECT vip.customer_id
    FROM (
        SELECT
            o2.customer_id,
            SUM(od2.quantity * od2.unit_price) AS total_spent
        FROM Orders o2
        INNER JOIN Order_Detail od2 ON od2.order_id = o2.order_id
        GROUP BY o2.customer_id
        HAVING SUM(od2.quantity * od2.unit_price) >= 5000000
    ) vip
)
ORDER BY c.full_name;
