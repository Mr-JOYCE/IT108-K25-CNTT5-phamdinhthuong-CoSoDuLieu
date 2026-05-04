USE session3;

CREATE TABLE ORDERS (
    OrderID INT PRIMARY KEY AUTO_INCREMENT,
    CustomerName VARCHAR(100),
    OrderDate DATETIME,
    TotalAmount DECIMAL(18, 2),
    Status VARCHAR(20), -- 'Completed', 'Canceled', 'Pending'
    IsDeleted TINYINT(1) DEFAULT 0
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

INSERT INTO ORDERS (CustomerName, OrderDate, TotalAmount, Status) VALUES
('Nguyễn Văn A', '2023-01-10', 500000, 'Completed'),
('Khách hàng vãng lai', '2023-02-15', 1200000, 'Canceled'),
('Trần Thị B', '2023-05-20', 300000, 'Canceled'),
('Lê Văn C', '2024-01-05', 850000, 'Completed');

-- ==========================================================
-- BAI TOAN: DON RAC DON HANG CU TRANG THAI "Canceled"
-- Gia su "don cu" la don co OrderDate < '2025-01-01'
-- ==========================================================

-- 1) DE XUAT GIAI PHAP A - HARD DELETE (xoa vat ly)
-- SQL:
-- DELETE FROM ORDERS
-- WHERE Status = 'Canceled'
--   AND OrderDate < '2025-01-01';
--
-- 2) DE XUAT GIAI PHAP B - SOFT DELETE (xoa logic)
-- SQL:
-- UPDATE ORDERS
-- SET IsDeleted = 1
-- WHERE Status = 'Canceled'
--   AND OrderDate < '2025-01-01';
--
-- 3) BANG SO SANH UU/NHUOC DIEM
-- Tieu chi              | Hard Delete                  | Soft Delete
-- --------------------- | ---------------------------- | ----------------------------
-- Dung luong luu tru    | Giam ngay                    | Khong giam ngay
-- Toc do truy van       | Nhanh hon do it ban ghi      | Can them dieu kien IsDeleted
-- Lich su/kiem toan     | Mat du lieu da xoa           | Van giu du lieu lich su
-- Kha nang khoi phuc    | Khong khoi phuc duoc         | Co the phuc hoi (IsDeleted=0)
-- Rui ro van hanh       | Cao neu xoa nham             | Thap hon, an toan nghiep vu
--
-- 4) LUA CHON CUOI CUNG: SOFT DELETE
-- Ly do: he thong sieu thi can giu lich su don huy de doi soat/kiem toan.

-- Bước 1: Đánh dấu đơn hủy cũ là đã xóa logic
UPDATE ORDERS
SET IsDeleted = 1
WHERE Status = 'Canceled'
  AND OrderDate < '2025-01-01';

-- Bước 2: Truy vấn cho hệ thống bán hàng (ẩn đơn đã dọn rác)
SELECT OrderID, CustomerName, OrderDate, TotalAmount, Status
FROM ORDERS
WHERE IsDeleted = 0;

-- Bước 3: Truy vấn cho kế toán (xem lại đơn hủy cũ đã dọn rác)
SELECT OrderID, CustomerName, OrderDate, TotalAmount, Status, IsDeleted
FROM ORDERS
WHERE Status = 'Canceled'
  AND OrderDate < '2025-01-01';

