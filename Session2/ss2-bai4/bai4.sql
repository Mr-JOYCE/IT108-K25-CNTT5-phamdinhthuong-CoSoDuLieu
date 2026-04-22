USE Session2;

-- Giải pháp 1: ALTER trực tiếp cột
-- ALTER TABLE USERS
-- MODIFY Phone VARCHAR(15);

-- Giải pháp 2: Tạo cột mới + migrate dữ liệu an toàn
-- ALTER TABLE USERS ADD Phone_new VARCHAR(15);
-- UPDATE USERS
-- SET Phone_new = CAST(Phone AS CHAR);
-- ALTER TABLE USERS DROP COLUMN Phone;
-- ALTER TABLE USERS CHANGE Phone_new Phone VARCHAR(15);

-- So sánh 2 giải pháp
-- | Tiêu chí                 | ALTER trực tiếp        | Tạo cột mới              |
-- | ------------------------ | ---------------------- | ------------------------ |
-- | Đơn giản                 | Rất đơn giản           |  Phức tạp                |
-- | Rủi ro downtime          |   Có thể lock bảng lớn |  An toàn hơn            |
-- | Ảnh hưởng 2 triệu record |   Có thể chậm / lock   |   Có thể kiểm soát batch |
-- | Khả năng rollback        |   Khó                  |   Dễ rollback            |
-- | Phù hợp production       |   Tùy DB engine        |   Rất an toàn            |

CREATE TABLE USERS (
    UserID INT PRIMARY KEY,
    UserName VARCHAR(100) NOT NULL,
    Phone INT NOT NULL
);

ALTER TABLE USERS ADD Phone_fresh VARCHAR(15);
SET SQL_SAFE_UPDATES = 0;

UPDATE USERS
SET Phone_new = LPAD(Phone, 15, '0');

SELECT Phone, Phone_new FROM USERS LIMIT 10;
ALTER TABLE USERS DROP COLUMN Phone;
ALTER TABLE USERS CHANGE Phone_ Phone VARCHAR(15);






