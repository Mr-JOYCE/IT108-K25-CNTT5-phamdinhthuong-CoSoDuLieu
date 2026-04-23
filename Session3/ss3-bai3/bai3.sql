USE session3;

-- 1. Phân tích I/O
-- 	Input: bảng CUSTOMERS
-- 	Cột cần dùng để lọc: City, LastPurchaseDate, Email, Status
-- 	Output: FullName, Email
-- 	Không dùng SELECT *
--      Lấy toàn bộ cột (không cần thiết) → tăng I/O, tốn RAM
--      Với bảng lớn → làm chậm truy vấn → gây bottleneck hệ thống
-- 2. Logic lọc (WHERE) 
-- 	Khách ở Hà Nội → City = 'Hà Nội'
--  Không mua > 6 tháng (trước 01/04/2026) → LastPurchaseDate < '2025-10-01'
--  Có Email → Email IS NOT NULL
--  Tài khoản hoạt động → Status = 'Active'
CREATE TABLE CUSTOMERS (
CustomerID INT PRIMARY KEY AUTO_INCREMENT,
FullName VARCHAR(100),
Email VARCHAR(100),
City VARCHAR(50),
LastPurchaseDate DATE,
Status VARCHAR(20),
Gender VARCHAR(10),
DateOfBirth DATE,
Points INT,
Address VARCHAR(255)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

INSERT INTO CUSTOMERS (FullName, Email, City, LastPurchaseDate, Status) VALUES
('Nguyên Văn A', 'anv@gmail.com', 'Hà Nội', '2025-05-20', 'Active' ), 
('Trần Thị B', 'btt@gmail.com', 'Hà Nội', '2026-02-10', 'Active' ),
('Lê Văn C', NULL, 'Hà Noi', '2025-01-15', 'Active' ),
('Phạm Minh D', 'dpm@gmail.com', 'Hà Nội', '2024-12-01', 'Locked' ),
('Hoàng An E', 'eha@gmail.com', 'TP HCM', '2025-03-01', 'Active' );

SELECT FullName, Email
FROM CUSTOMERS
WHERE City = 'Hà Nội'
  AND LastPurchaseDate < '2025-10-01'
  AND Email IS NOT NULL
  AND Status = 'Active';
