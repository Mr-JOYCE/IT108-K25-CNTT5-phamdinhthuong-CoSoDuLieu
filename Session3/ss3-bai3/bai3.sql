USE session3;

-- ==========================================================
-- 1) PHAN TICH I/O
-- Input:
--   - Bang quet: CUSTOMERS (du lieu lon: hang trieu ban ghi)
--   - Cot can dung de loc: City, LastPurchaseDate, Email, Status
-- Output:
--   - Chi tra ve: FullName, Email (de nap vao he thong gui mail)
--
-- Tai sao SELECT * la sai lam?
--   - Lay tat ca cot (nhieu cot khong can thiet) => tang I/O doc dia, ton RAM.
--   - Tang kich thuoc du lieu truyen qua mang/noi bo.
--   - De gay nghen co chai khi truy van tren bang lon.
-- ==========================================================
-- 2) THIET KE LOGIC LOC (WHERE)
--   a) Khach o Ha Noi: City = 'Hà Nội'
--   b) Khong mua hon 6 thang tinh tu 01/04/2026:
--      LastPurchaseDate < '2025-10-01'
--   c) Loai bo bay du lieu email:
--      Email IS NOT NULL va TRIM(Email) <> ''
--   d) Loai bo tai khoan bi khoa:
--      Status <> 'Locked'
-- ==========================================================
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
('Nguyễn Văn A', 'anv@gmail.com', 'Hà Nội', '2025-05-20', 'Active' ), 
('Trần Thị B', 'btt@gmail.com', 'Hà Nội', '2026-02-10', 'Active' ),
('Lê Văn C', NULL, 'Hà Noi', '2025-01-15', 'Active' ),
('Phạm Minh D', 'dpm@gmail.com', 'Hà Nội', '2024-12-01', 'Locked' ),
('Hoàng An E', 'eha@gmail.com', 'TP HCM', '2025-03-01', 'Active' );

-- 3) TRIEN KHAI CODE
-- Cau lenh dap ung dung nghiep vu cua sep
SELECT FullName, Email
FROM CUSTOMERS
WHERE City = 'Hà Nội'
  AND LastPurchaseDate < '2025-10-01'
  AND Email IS NOT NULL
  AND TRIM(Email) <> ''
  AND Status <> 'Locked';
