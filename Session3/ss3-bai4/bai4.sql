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

-- Vấn đề:
-- SELECT * 
-- FROM ORDERS 
-- WHERE Status = 'Completed';
-- Nhược điểm:
-- Vẫn phải quét toàn bộ bảng (bao gồm đơn bị hủy)
-- Không tối ưu khi dữ liệu lớn

-- Giải pháp:
-- 1. Hard Delete (Xóa vật lý)
-- DELETE FROM ORDERS
-- WHERE Status = 'Canceled';
-- 2. Soft Delete (Xóa logic)
-- UPDATE ORDERS
-- SET IsDeleted = 1
-- WHERE Status = 'Canceled';

-- So Sánh 2 phương pháp
-- 		Tiêu chí				Hard Delete					Soft Delete
-- 	Dung lượng ổ cứng			Giảm mạnh	 				Không giảm
-- 	Tốc độ truy vấn	 			Nhanh hơn (ít dữ liệu)	 	Cần filter thêm
-- 	Lịch sử kế toán	 			Mất dữ liệu	 				Giữ nguyên
-- 	Khôi phục dữ liệu	 		Không thể	 				Có thể

-- Chọn giải pháp: Soft Delete

-- Bước 1: Đánh dấu đơn bị hủy
UPDATE ORDERS
SET IsDeleted = 1
WHERE Status = 'Canceled';

-- Bước 2: Truy vấn cho hệ thống bán hàng (ẩn đơn hủy)
SELECT *
FROM ORDERS
WHERE IsDeleted = 0;

-- Bước 3: Truy vấn cho kế toán (xem đơn hủy)
SELECT *
FROM ORDERS
WHERE Status = 'Canceled';

