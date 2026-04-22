use Session2;

-- Dựa trên bảng CUSTOMERS trong bối cảnh bài toán (gửi email sinh nhật bị lỗi).
-- Các ràng buộc hiện tại đang thiếu 2 nhóm chính: ràng buộc dữ liệu bắt buộc (NOT NULL) và ràng buộc miền giá trị (CHECK).

CREATE TABLE CUSTOMERS (
CustomerID INT PRIMARY KEY,
FullName VARCHAR(100),
Email VARCHAR(100), 
Age INT
);

ALTER TABLE CUSTOMERS
MODIFY Email VARCHAR(255) NOT NULL;

ALTER TABLE CUSTOMERS
ADD CONSTRAINT uq_customers_email UNIQUE (Email);

ALTER TABLE CUSTOMERS
ADD CONSTRAINT chk_customers_age
CHECK (Age >= 0);
