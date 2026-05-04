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

-- ==========================================================
-- PHAN TICH LOI "DONG GIA TOAN SIEU THI"
-- ==========================================================
-- Loi nghiep vu xay ra khi cau lenh UPDATE bo sot dieu kien loc theo nganh hang.
-- Cau lenh sai (vi du):
-- UPDATE PRODUCTS
-- SET OriginalPrice = OriginalPrice * 0.9;
--
-- HAU QUA:
-- 1) Tat ca san pham deu bi giam gia, bao gom ca thuc pham, do gia dung,...
-- 2) Vi cap nhat hang loat khong co WHERE, gia toan he thong bi sai nghiep vu.
-- 3) Gay "tham hoa dong gia toan sieu thi" do nhan vien thao tac nham pham vi du lieu.

-- ==========================================================
-- CAU LENH UPDATE DUNG NGHIEP VU
-- Chi giam 10% cho san pham thuoc nganh hang "Electronics"
-- ==========================================================
UPDATE PRODUCTS
SET OriginalPrice = OriginalPrice * 0.9
WHERE Category = 'Electronics';