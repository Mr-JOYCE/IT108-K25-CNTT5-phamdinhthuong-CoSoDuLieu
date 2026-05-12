DROP PROCEDURE IF EXISTS Seed_Pharmacy_Inventory;

DROP TABLE IF EXISTS Pharmacy_Inventory;

CREATE TABLE Pharmacy_Inventory (
    Inventory_ID INT AUTO_INCREMENT PRIMARY KEY,
    Drug_Name VARCHAR(255) NOT NULL,
    Batch_Number VARCHAR(50) NOT NULL,
    Expiry_Date DATE NOT NULL,
    Quantity INT NOT NULL
) ENGINE=InnoDB;

DELIMITER //

CREATE PROCEDURE Seed_Pharmacy_Inventory(IN p_rows INT)
BEGIN
    DECLARE i INT DEFAULT 1;
    DECLARE dn VARCHAR(255);
    DECLARE ed DATE;
    DECLARE batch VARCHAR(50);
    DECLARE qty INT;

    WHILE i <= p_rows DO
        IF i MOD 200 = 0 THEN
            SET dn = 'Paracetamol Benchmark';
            SET ed = DATE '2027-03-01';
        ELSE
            SET dn = ELT(
                MOD(i, 5) + 1,
                'Paracetamol',
                'Amoxicillin Capsule',
                'Ibuprofen',
                'Metformin',
                'Vitamin C'
            );
            SET ed = DATE_ADD(DATE '2025-06-01', INTERVAL MOD(i, 730) DAY);
        END IF;

        SET batch = CONCAT('B-', LPAD(i, 10, '0'));
        SET qty = 10 + MOD(i, 500);

        INSERT INTO Pharmacy_Inventory (Drug_Name, Batch_Number, Expiry_Date, Quantity)
        VALUES (dn, batch, ed, qty);

        SET i = i + 1;
    END WHILE;
END //

DELIMITER ;

CALL Seed_Pharmacy_Inventory(15000);

ANALYZE TABLE Pharmacy_Inventory;

SET @q_drug = 'Paracetamol Benchmark';
SET @q_date = DATE '2027-03-01';

SELECT '--- Hai index đơn: (Drug_Name) và (Expiry_Date)' AS step;

CREATE INDEX ix_pharm_inv_drug_name ON Pharmacy_Inventory (Drug_Name);
CREATE INDEX ix_pharm_inv_expiry ON Pharmacy_Inventory (Expiry_Date);
ANALYZE TABLE Pharmacy_Inventory;

SELECT 'Query: tra cứu song song theo Drug_Name và Expiry_Date' AS hint;
EXPLAIN
SELECT Inventory_ID,
       Drug_Name,
       Batch_Number,
       Expiry_Date,
       Quantity
FROM Pharmacy_Inventory
WHERE Drug_Name = @q_drug
  AND Expiry_Date = @q_date
LIMIT 100;

SET @ts_start = NOW(6);
SELECT COUNT(*) INTO @cnt_single
FROM Pharmacy_Inventory
WHERE Drug_Name = @q_drug
  AND Expiry_Date = @q_date;
SELECT TIMESTAMPDIFF(MICROSECOND, @ts_start, NOW(6)) / 1000000.0 AS select_seconds_two_single_indexes;

DROP INDEX ix_pharm_inv_drug_name ON Pharmacy_Inventory;
DROP INDEX ix_pharm_inv_expiry ON Pharmacy_Inventory;

SELECT '--- Composite index: (Drug_Name, Expiry_Date)' AS step;

CREATE INDEX ix_pharm_inv_drug_expiry ON Pharmacy_Inventory (Drug_Name, Expiry_Date);
ANALYZE TABLE Pharmacy_Inventory;

EXPLAIN
SELECT Inventory_ID,
       Drug_Name,
       Batch_Number,
       Expiry_Date,
       Quantity
FROM Pharmacy_Inventory
WHERE Drug_Name = @q_drug
  AND Expiry_Date = @q_date
LIMIT 100;

SET @ts_start = NOW(6);
SELECT COUNT(*) INTO @cnt_composite
FROM Pharmacy_Inventory
WHERE Drug_Name = @q_drug
  AND Expiry_Date = @q_date;
SELECT TIMESTAMPDIFF(MICROSECOND, @ts_start, NOW(6)) / 1000000.0 AS select_seconds_composite_index;

SELECT @cnt_single AS cnt_two_single_indexes,
       @cnt_composite AS cnt_composite_index,
       IF(@cnt_single = @cnt_composite, 'Đếm khớp giữa hai bước.', 'Sai lệch — cần rà soát.') AS kt_khoa;

SELECT '--- LIKE ''%chuỗi%'' không có tiền tố cố định ⇒ index prefix trên Drug_Name không dùng được (ví dụ LIKE ''%Bench%'')' AS step;

EXPLAIN
SELECT Inventory_ID,
       Drug_Name,
       Batch_Number,
       Expiry_Date,
       Quantity
FROM Pharmacy_Inventory
WHERE Drug_Name LIKE '%Bench%'
LIMIT 100;

SELECT '--- LIKE ''Paracetamol Bench%'' có tiền tố + phối hợp Expiry_Date ⇒ có thể dùng composite (Drug_Name, Expiry_Date)' AS like_prefix_demo;

EXPLAIN
SELECT Inventory_ID,
       Drug_Name,
       Batch_Number,
       Expiry_Date,
       Quantity
FROM Pharmacy_Inventory
WHERE Drug_Name LIKE 'Paracetamol Bench%'
  AND Expiry_Date = @q_date
LIMIT 100;

DROP PROCEDURE IF EXISTS Seed_Pharmacy_Inventory;

SELECT 'Hai chỉ mục đơn độc lập ⇒ mỗi lần ghi có thể phải cập nhật nhiều chỉ mục; truy vấn hai điều kiện đẳng thức thường được tối ưu khác nhau (index_merge / chọn một chỉ mục) tùy bộ tối ưu và thống kê. Composite (Drug_Name, Expiry_Date) gom một lần tra trên một cây chỉ mục khi có cả hai cột trong WHERE với '=', rất đúng bài tra cứu lô + hạn.' AS ghichu_so_sanh_hai_vs_composite;

SELECT 'Gợi ý FULLTEXT (InnoDB): ALTER TABLE Pharmacy_Inventory ADD FULLTEXT INDEX ft_drug(Drug_Name); -- sau đó thử MATCH(Drug_Name) AGAINST(''Paracetamol Benchmark*'' IN BOOLEAN MODE).' AS ghichu_fulltext;

SELECT 'Khác: chuẩn hóa từ khóa, tra bằng LIKE ''tiền_tố%'' khi có thể, cột generated / bảng tìm kiếm chuyên dụng nếu dữ liệu rất lớn (đề ví dụ ~2 triệu+ dòng).' AS ghichu_quy_mo_lon;
