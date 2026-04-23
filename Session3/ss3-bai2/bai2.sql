USE session3;

CREATE TABLE SHIPPERS (
ShipperID INT PRIMARY KEY AUTO_INCREMENT,
ShipperName VARCHAR(255),
Phone VARCHAR(20)
);

-- Lỗi 1: Thiếu dấu nháy đơn đóng sau "Giao Hàng Nhanh"
INSERT INTO SHIPPERS (ShipperName, Phone)
VALUES ('Giao Hàng Nhanh', '0901234567' );

-- Lỗi 2: Dữ liệu bị NULL (lỗi logic)
-- Bảng có 3 cột: ShipperID, ShipperName, Phone. Nhưng chỉ truyền 1 giá trị
-- SQL hiểu:
-- 		ShipperID → auto_increment 
-- 		ShipperName → 'Viettel Post'
-- 		Phone → không có → NULL
-- Không phải lỗi cú pháp → nên vẫn chạy
INSERT INTO SHIPPERS (ShipperName, phone)
VALUES ('Viettel Post', '0992982827');